###*
 * @package     CleverStyle Music
 * @category    app
 * @author      Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright   Copyright (c) 2014, Nazar Mokrynskyi
 * @license     MIT License, see license.txt
###
music_library		= cs.music_library

cs.music_playlist	=
	get_all			: (callback) ->
		callback	= (callback || ->).bind(@)
		playlist	= localStorage.playlist
		if playlist
			playlist	= JSON.parse(playlist)
			if playlist?.length
				callback(playlist)
				return
		@refresh ->
			@get_all(callback)
	current			: (callback) ->
		callback	= (callback || ->).bind(@)
		playlist	= localStorage.playlist
		if playlist
			playlist	= JSON.parse(playlist)
			if playlist?.length
				position	= localStorage.position || 0
				if position < playlist.length
					localStorage.position	= position
					callback(playlist[position])
					return
		@refresh ->
			@next(callback)
		return
	set_current		: (position) ->
		localStorage.position	= position
	set_current_id	: (id) ->
		@get_all (all) ->
			localStorage.position	= all.indexOf(id)
	prev			: (callback) ->
		callback	= (callback || ->).bind(@)
		playlist	= localStorage.playlist
		if playlist
			playlist	= JSON.parse(playlist)
			if playlist?.length
				position	= localStorage.position || -1
				if position > 0
					--position
					localStorage.position	= position
					callback(playlist[position])
		return
	next			: (callback) ->
		callback	= (callback || ->).bind(@)
		playlist	= localStorage.playlist
		if playlist
			playlist	= JSON.parse(playlist)
			if playlist?.length
				position	= localStorage.position || -1
				if position < (playlist.length - 1)
					++position
					localStorage.position	= position
					callback(playlist[position])
					return
				else if cs.music_settings.repeat == 'none'
					return
		@refresh ->
			@next(callback)
		return
	set				: (all, callback) ->
		localStorage.original_playlist	= JSON.stringify(all)
		delete localStorage.playlist
		@refresh(callback)
	append			: (new_items) ->
		original_playlist				= JSON.parse(localStorage.original_playlist)
		original_playlist				= original_playlist.concat(new_items).unique()
		localStorage.original_playlist	= JSON.stringify(original_playlist)
		if cs.music_settings.shuffle
			new_items.shuffle()
		playlist				= JSON.parse(localStorage.playlist)
		playlist				= playlist.concat(new_items).unique()
		localStorage.playlist	= JSON.stringify(playlist)
	refresh			: (callback) ->
		callback	= (callback || ->).bind(@)
		playlist	= JSON.parse(localStorage.original_playlist || '[]')
		if playlist.length
			if cs.music_settings.shuffle
				playlist.shuffle()
			localStorage.playlist	= JSON.stringify(playlist)
			delete localStorage.position
			callback(playlist)
		else
			music_library.get_all (all) =>
				if all.length
					for value, i in all
						all[i] = value.id
					@set(all, callback)
				else if confirm(_('library-empty-want-to-rescan'))
					$(document.body).addClass('library-rescan')
					document.querySelector('cs-music-library-rescan').open()
		return
