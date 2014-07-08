###*
 * @package     CleverStyle Music
 * @category    app
 * @author      Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright   Copyright (c) 2014, Nazar Mokrynskyi
 * @license     MIT License, see license.txt
###
if !window.cs
	window.cs = {}
do ->
	if !window.indexedDB
		alert "Indexed DB is not supported O_o"
		return
	db				= null
	on_db_ready		= []
	music_storage	= navigator.getDeviceStorage('music')
	request 		= indexedDB.open('music_db', 1)
	request.onsuccess = ->
		db = request.result
		while callback = on_db_ready.shift()
			callback()
		return
	request.onerror = (e) ->
		console.error(e)
		return
	request.onupgradeneeded = ->
		db = request.result
		if db.objectStoreNames.contains('music')
			db.deleteObjectStore('music')
		music_store = db.createObjectStore(
			'music'
			keyPath			: 'id'
			autoIncrement	: true
		)
		music_store.createIndex(
			'name'
			'name'
			unique	: true
		)
		meta_store = db.createObjectStore(
			'meta'
			keyPath	: 'id'
		)
		meta_store.createIndex('title', 'title')
		meta_store.createIndex('artist', 'artist')
		meta_store.createIndex('album', 'album')
		meta_store.createIndex('genre', 'genre')
		meta_store.createIndex('year', 'year')
		db.transaction.oncomplete	= ->
			while callback = on_db_ready.shift()
				callback()
		return
	library_size		= -1
	cs.music_library	=
		add					: (name, callback) ->
			callback	= (callback || ->).bind(@)
			@onready ->
				db
					.transaction(['music'], 'readwrite')
						.objectStore('music')
							.put(
								name	: name
							)
							.onsuccess = callback
		parse_metadata		: (name, callback) ->
			callback	= (callback || ->).bind(@)
			db
				.transaction(['music'])
					.objectStore('music')
						.index('name')
							.get(name).onsuccess	= ->
								if @result
									data	= @result
									music_storage.get(data.name).onsuccess = ->
										if @result
											insert_meta			= {id : data.id}
											metadata_loaded		= false
											duration_loaded		= false
											proceed_insertion	= ->
												db
													.transaction(['meta'], 'readwrite')
														.objectStore('meta')
															.put(insert_meta)
															.onsuccess = ->
																callback()
											asset				= AV.Asset.fromURL(window.URL.createObjectURL(@result))
											asset.get('metadata', (metadata) ->
												if !metadata
													return
												genre	= metadata.genre || ''
												genre	= new String(genre).replace(/^\(?([0-9]+)\)?$/, (match, genre_index) ->
													return genres_list[parseInt(genre_index)]
												)
												$.extend(
													insert_meta
													title	: metadata.title || ''
													artist	: metadata.artist || ''
													album	: metadata.album || ''
													genre	: genre || ''
													year	: metadata.year || metadata.recordingTime || ''
												)
												if duration_loaded
													proceed_insertion()
												else
													metadata_loaded	= true
											)
											asset.get('duration', (duration) ->
												duration				= duration || 0
												insert_meta.duration	= Math.floor(duration / 1000)
												if metadata_loaded
													proceed_insertion()
												else
													duration_loaded	= true
											)
		get					: (id, callback) ->
			callback	= (callback || ->).bind(@)
			@onready ->
				db
					.transaction(['music'])
						.objectStore('music')
							.get(id).onsuccess	= ->
								result = @result
								if result
									callback(result)
		get_meta			: (id, callback) ->
			callback	= (callback || ->).bind(@)
			@onready ->
				db
					.transaction(['meta'])
						.objectStore('meta')
							.get(id).onsuccess	= ->
								result = @result
								if result
									callback(result)
		get_all				: (callback, filter) ->
			callback	= (callback || ->).bind(@)
			filter		= filter || -> true
			@onready ->
				all					= []
				db
					.transaction(['music'])
						.objectStore('music')
							.openCursor().onsuccess	= ->
								result	= @result
								if result
									if filter(result.value)
										all.push(result.value)
									result.continue()
								else
									callback(all)
		get_next_id_to_play	: (callback) ->
			callback			= (callback || ->).bind(@)
			current_playlist	= localStorage.getItem('current_playlist')
			if current_playlist
				current_playlist	= JSON.parse(current_playlist)
				next_item			= current_playlist.pop()
				localStorage.setItem('current_playlist', JSON.stringify(current_playlist))
				callback(next_item)
			else
				@get_all (all) ->
					current_playlist	= []
					all.forEach (value) ->
						current_playlist.push(value.id)
					current_playlist.shuffle()
					next_item	= current_playlist.pop()
					if current_playlist.length
						localStorage.setItem('current_playlist', JSON.stringify(current_playlist))
					else
						@clean_playlist()
					callback(next_item)
		del					: (id) ->
			@onready ->
				db
					.transaction(['music'], 'readwrite')
						.objectStore('music')
							.delete(id)
							.onsuccess = ->
								db
									.transaction(['meta'], 'readwrite')
										.objectStore('meta')
											.delete(id)
		clean_playlist		: ->
			localStorage.removeItem('current_playlist')
		size				: (callback, filter) ->
			callback	= (callback || ->).bind(@)
			filter		= filter || -> true
			@onready ->
				if library_size >= 0 && !filter
					callback(library_size)
				calculated_size	= 0
				db
					.transaction(['music'])
						.objectStore('music')
							.openCursor().onsuccess	= ->
								result	= @result
								if result
									if !filter || filter(result.value)
										++calculated_size
									result.continue()
								else
									if !filter
										library_size = calculated_size
									callback(calculated_size)
		rescan				: (done_callback) ->
			done_callback	= (done_callback || ->).bind(@)
			@onready ->
				new_files		= []
				remove_old_files	= =>
					@get_all (all) =>
						all.forEach (file) =>
							if file.name not in new_files
								@del(file.id)
							return
						done_callback()
				do =>
					music_storage	= navigator.getDeviceStorage('music')
					cursor			= music_storage.enumerate()
					cursor.onsuccess = =>
						if cursor.result
							file = cursor.result
							db
								.transaction(['music'])
									.objectStore('music')
										.index('name')
											.get(file.name).onsuccess	= (e) =>
												if !e.target.result
													@add(file.name, ->
														@parse_metadata(file.name, ->
															new_files.push(file.name)
															cursor.continue()
														)
													)
												else
													new_files.push(file.name)
													cursor.continue()
						else
							remove_old_files()
					cursor.onerror = ->
						console.error(@error.name)
		onready				: (callback) ->
			callback	= (callback || ->).bind(@)
			if db
				callback()
			else
				on_db_ready.push(callback)
			return
	genres_list = ['Blues', 'Classic Rock', 'Country', 'Dance', 'Disco', 'Funk', 'Grunge', 'Hip-Hop', 'Jazz', 'Metal', 'New Age', 'Oldies', 'Other', 'Pop', 'R&B', 'Rap', 'Reggae', 'Rock', 'Techno', 'Industrial', 'Alternative', 'Ska', 'Death Metal', 'Pranks', 'Soundtrack', 'Euro-Techno', 'Ambient', 'Trip-Hop', 'Vocal', 'Jazz+Funk', 'Fusion', 'Trance', 'Classical', 'Instrumental', 'Acid', 'House', 'Game', 'Sound Clip', 'Gospel', 'Noise', 'AlternRock', 'Bass', 'Soul', 'Punk', 'Space', 'Meditative', 'Instrumental Pop', 'Instrumental Rock', 'Ethnic', 'Gothic', 'Darkwave', 'Techno-Industrial', 'Electronic', 'Pop-Folk', 'Eurodance', 'Dream', 'Southern Rock', 'Comedy', 'Cult', 'Gangsta Rap', 'Top 40', 'Christian Rap', 'Pop / Funk', 'Jungle', 'Native American', 'Cabaret', 'New Wave', 'Psychedelic', 'Rave', 'Showtunes', 'Trailer', 'Lo-Fi', 'Tribal', 'Acid Punk', 'Acid Jazz', 'Polka', 'Retro', 'Musical', 'Rock & Roll', 'Hard Rock', 'Folk', 'Folk-Rock', 'National Folk', 'Swing', 'Fast Fusion', 'Bebob', 'Latin', 'Revival', 'Celtic', 'Bluegrass', 'Avantgarde', 'Gothic Rock', 'Progressive Rock', 'Psychedelic Rock', 'Symphonic Rock', 'Slow Rock', 'Big Band', 'Chorus', 'Easy Listening', 'Acoustic', 'Humour', 'Speech', 'Chanson', 'Opera', 'Chamber Music', 'Sonata', 'Symphony', 'Booty Bass', 'Primus', 'Porn Groove', 'Satire', 'Slow Jam', 'Club', 'Tango', 'Samba', 'Folklore', 'Ballad', 'Power Ballad', 'Rhythmic Soul', 'Freestyle', 'Duet', 'Punk Rock', 'Drum Solo', 'A Cappella', 'Euro-House', 'Dance Hall', 'Goa', 'Drum & Bass', 'Club-House', 'Hardcore', 'Terror', 'Indie', 'BritPop', 'Negerpunk', 'Polsk Punk', 'Beat', 'Christian Gangsta Rap', 'Heavy Metal', 'Black Metal', 'Crossover', 'Contemporary Christian', 'Christian Rock', 'Merengue', 'Salsa', 'Thrash Metal', 'Anime', 'JPop', 'Synthpop', 'Abstract', 'Art Rock', 'Baroque', 'Bhangra', 'Big Beat', 'Breakbeat', 'Chillout', 'Downtempo', 'Dub', 'EBM', 'Eclectic', 'Electro', 'Electroclash', 'Emo', 'Experimental', 'Garage', 'Global', 'IDM', 'Illbient', 'Industro-Goth', 'Jam Band', 'Krautrock', 'Leftfield', 'Lounge', 'Math Rock', 'New Romantic', 'Nu-Breakz', 'Post-Punk', 'Post-Rock', 'Psytrance', 'Shoegaze', 'Space Rock', 'Trop Rock', 'World Music', 'Neoclassical', 'Audiobook', 'Audio Theatre', 'Neue Deutsche Welle', 'Podcast', 'Indie Rock', 'G-Funk', 'Dubstep', 'Garage Rock', 'Psybient']
