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
		@sort(all, (sorted) =>
			localStorage.original_playlist	= JSON.stringify(sorted)
			delete localStorage.playlist
			@refresh(callback)
		)
	append			: (new_items, callback) ->
		original_playlist				= JSON.parse(localStorage.original_playlist)
		original_playlist				= original_playlist.concat(new_items).unique()
		@sort(original_playlist, (sorted) ->
			localStorage.original_playlist	= JSON.stringify(sorted)
		)
		playlist				= JSON.parse(localStorage.playlist)
		save_playlist	= (list) ->
			playlist				= playlist.concat(list).unique()
			localStorage.playlist	= JSON.stringify(playlist)
			callback()
		if cs.music_settings.shuffle
			new_items.shuffle()
			save_playlist(new_items)
		else
			@sort(new_items, (sorted) ->
				save_playlist(sorted)
			)
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
	sort			: (all, callback) ->
		index			= 0
		list			= []
		count			= all.length
		get_next_item	= =>
			if index < count
				music_library.get_meta(all[index], (data) =>
					artist_title	= []
					if data.artist
						artist_title.push(data.artist)
					if data.title
						artist_title.push(data.title)
					artist_title	= artist_title.join(' — ') || _('unknown')
					list.push(
						id		: data.id
						value	: artist_title
					)
					data			= null
					artist_title	= null
					++index
					get_next_item()
				)
			else
				list.sort (a, b) ->
					a	= a.value
					b	= b.value
					if a == b then 0
					else if a < b then -1
					else 1
				for value, i in list
					list[i] = value.id
				callback(list)
		get_next_item()

