###*
 * @package     CleverStyle Music
 * @category    Web Components
 * @author      Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright   Copyright (c) 2014, Nazar Mokrynskyi
 * @license     MIT License, see license.txt
###

music_storage	= navigator.getDeviceStorage('music')
music_library	= cs.music_library
player			= null

Polymer(
	'cs-music-player',
	title	: 'Unknown'
	artist	: 'Unknown'
	rescan	: ->
		music_library.rescan ->
			@clean_playlist()
			alert 'Rescanned successfully, playlist refreshed'
	play	: ->
		element = @
		play_button = element.shadowRoot.querySelector('[icon=play]')
		if player
			if player.playing
				player.pause()
				play_button.icon = 'play'
			else
				player.play()
				play_button.icon = 'pause'
		else
			music_library.get_next_id_to_play (id) ->
				music_library.get(id, (data) ->
					music_storage.get(data.name).onsuccess = ->
						player = AV.Player.fromURL(window.URL.createObjectURL(@result))
						# Change channel type to play in background
						player.on('ready', ->
							@device.device.node.context.mozAudioChannelType = 'content'
						)
						player.play()
						play_button.icon = 'pause'
						music_library.get_meta(id, (data) ->
							if data
								element.title	= data.title || 'Unknown'
								element.artist	= data.artist || 'Unknown'
								if data.album
									element.artist += ": #{data.album}"
							else
								element.title	= 'Unknown'
								element.artist	= 'Unknown'
						)
				)
	prev	: ->
		alert 'No implemented yet'
	next	: ->
		alert 'No implemented yet'
)
