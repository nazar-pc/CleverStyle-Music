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
	db			= null
	on_db_ready	= []
	request 	= indexedDB.open('music_db', 1)
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
		store = db.createObjectStore(
			'music'
			keyPath			: 'id'
			autoIncrement	: true
		)
		store.createIndex(
			'name'
			'name'
			unique	: true
		)
		db.transaction.oncomplete	= ->
			while callback = on_db_ready.shift()
				callback()
		return
	library_size		= -1
	cs.music_library	=
		add					: (name) ->
			@.onready ->
				transaction	= db.transaction(['music'], 'readwrite')
				store		= transaction.objectStore('music')
				try
					store.add(
						name	: name
					)
				catch e
					#
		get					: (id, callback) ->
			@.onready ->
				db
					.transaction(['music'])
						.objectStore('music')
							.get(id).onsuccess	= ->
								result = @.result
								if result
									callback(result)
		get_all				: (callback, filter) ->
			@.onready ->
				all					= []
				db
					.transaction(['music'])
						.objectStore('music')
							.openCursor().onsuccess	= ->
								result	= @.result
								if result
									if !filter || filter(result.value)
										all.push(result.value)
									result.continue()
								else
									callback(all)
		get_next_id_to_play	: (callback) ->
			current_playlist = localStorage.getItem('current_playlist')
			if current_playlist
				current_playlist	= JSON.parse(current_playlist)
				next_item			= current_playlist.pop()
				localStorage.setItem('current_playlist', JSON.stringify(current_playlist))
				callback(next_item)
			else
				@.get_all (all) ->
					current_playlist	= []
					all.forEach (value) ->
						current_playlist.push(value.id)
					current_playlist.shuffle()
					next_item	= current_playlist.pop()
					if current_playlist.length
						localStorage.setItem('current_playlist', JSON.stringify(current_playlist))
					else
						@.clean_playlist()
					callback(next_item)
		clean_playlist		: ->
			localStorage.removeItem('current_playlist')
		size				: (callback, filter) ->
			@.onready ->
				if library_size >= 0 && !filter
					callback(library_size)
				calculated_size	= 0
				db
					.transaction(['music'])
						.objectStore('music')
							.openCursor().onsuccess	= ->
								result	= @.result
								if result
									if !filter || filter(result.value)
										++calculated_size
									result.continue()
								else
									if !filter
										library_size = calculated_size
									callback(calculated_size)
		onready				: (callback) ->
			if db
				callback()
			else
				on_db_ready.push(callback)
			return

