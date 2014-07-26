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
	refresh			: (callback) ->
		callback	= (callback || ->).bind(@)
		music_library.get_all (all) ->
			if all.length
				playlist	= []
				all.forEach (data) ->
					playlist.push(data.id)
				if cs.music_settings.shuffle
					playlist.shuffle()
				localStorage.playlist	= JSON.stringify(playlist)
				localStorage.position	= 0
				callback(playlist)
			else
				if confirm(_('library-empty-want-to-rescan'))
					$(document.body).addClass('library-rescan')
					document.querySelector('cs-music-library-rescan').open()
		return
