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
			@onready ->
				db
					.transaction(['music'], 'readwrite')
						.objectStore('music')
							.put(
								name	: name
							)
		get					: (id, callback) ->
			callback	= callback.bind(@)
			@onready ->
				db
					.transaction(['music'])
						.objectStore('music')
							.get(id).onsuccess	= ->
								result = @result
								if result
									callback(result)
		get_all				: (callback, filter) ->
			callback	= callback.bind(@)
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
			callback			= callback.bind(@)
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
		clean_playlist		: ->
			localStorage.removeItem('current_playlist')
		size				: (callback, filter) ->
			callback	= callback.bind(@)
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
		rescan				: (callback) ->
			callback	= callback.bind(@)
			@onready ->
				new_files		= []
				remove_old_files	= =>
					@get_all (all) =>
						all.forEach (file) =>
							if file.name not in new_files
								@del(file.id)
							return
						callback()
				do =>
					music_storage	= navigator.getDeviceStorage('music')
					cursor			= music_storage.enumerate()
					cursor.onsuccess = =>
						if cursor.result
							file = cursor.result
							@add(file.name)
							new_files.push(file.name)
							cursor.continue()
						else
							remove_old_files()
					cursor.onerror = ->
						console.error(@error.name)
		onready				: (callback) ->
			callback	= callback.bind(@)
			if db
				callback()
			else
				on_db_ready.push(callback)
			return

