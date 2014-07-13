###*
 * @package     CleverStyle Music
 * @category    app
 * @author      Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright   Copyright (c) 2014, Nazar Mokrynskyi
 * @license     MIT License, see license.txt
###
do ->
	music_library		= cs.music_library
	cs.music_playlist	=
		get_all		: (callback) ->
			callback	= (callback || ->).bind(@)
			playlist	= localStorage.getItem('playlist')
			if playlist
				playlist	= JSON.parse(playlist)
				if playlist?.length
					callback(playlist)
					return
			@refresh ->
				@get_all(callback)
		current		: (callback) ->
			callback	= (callback || ->).bind(@)
			playlist	= localStorage.getItem('playlist')
			if playlist
				playlist	= JSON.parse(playlist)
				if playlist?.length
					position	= localStorage.getItem('position') || 0
					if position < playlist.length
						localStorage.setItem('position', position)
						callback(playlist[position])
						return
			@refresh ->
				@next(callback)
			return
		set_current	: (position) ->
			localStorage.setItem('position', position)
		prev		: (callback) ->
			callback	= (callback || ->).bind(@)
			playlist	= localStorage.getItem('playlist')
			if playlist
				playlist	= JSON.parse(playlist)
				if playlist?.length
					position	= localStorage.getItem('position') || -1
					if position > 0
						--position
						localStorage.setItem('position', position)
						callback(playlist[position])
			return
		next		: (callback) ->
			callback	= (callback || ->).bind(@)
			playlist	= localStorage.getItem('playlist')
			if playlist
				playlist	= JSON.parse(playlist)
				if playlist?.length
					position	= localStorage.getItem('position') || -1
					if position < (playlist.length - 1)
						++position
						localStorage.setItem('position', position)
						callback(playlist[position])
						return
			@refresh ->
				@next(callback)
			return
		refresh		: (callback) ->
			callback	= (callback || ->).bind(@)
			music_library.get_all (all) ->
				if all.length
					playlist	= []
					all.forEach (data) ->
						playlist.push(data.id)
					playlist.shuffle()
					localStorage.setItem('playlist', JSON.stringify(playlist))
					localStorage.removeItem('position')
					callback(playlist)
				else
					alert('Library is empty')
			return
