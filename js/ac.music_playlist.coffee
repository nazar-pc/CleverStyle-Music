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
				@next (id) ->
					callback(id)
			return
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
				@next (id) ->
					callback(id)
			return
		refresh		: (callback) ->
			callback			= (callback || ->).bind(@)
			music_library.get_all (all) ->
				playlist	= []
				all.forEach (data) ->
					playlist.push(data.id)
				playlist.shuffle()
				if playlist.length
					localStorage.setItem('playlist', JSON.stringify(playlist))
				callback(playlist)
			localStorage.removeItem('position')
			return
