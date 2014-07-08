###*
 * @package     CleverStyle Music
 * @category    Web Components
 * @author      Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright   Copyright (c) 2014, Nazar Mokrynskyi
 * @license     MIT License, see license.txt
###

music_storage	= navigator.getDeviceStorage('music')
music_library	= cs.music_library

Polymer(
	'cs-music-player',
	header	: ''
	rescan	: ->
		music_library.rescan ->
			@clean_playlist()
			alert 'Rescanned successfully, playlist refreshed'
	play	: ->
		root = @
		music_library.get_next_id_to_play (id) ->
			music_library.get(id, (data) ->
				music_storage.get(data.name).onsuccess = ->
					player = AV.Player.fromURL(window.URL.createObjectURL(@result))
					# Change channel type to play in background
					player.on('ready', ->
						@device.device.node.context.mozAudioChannelType = 'content'
					)
					player.play()
					music_library.get_meta(id, (data) ->
						if data
							root.header = "#{data.title} - #{data.artist}"
						else
							root.header = ''
					)
			)
)
