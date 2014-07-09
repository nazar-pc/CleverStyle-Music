###*
 * @package     CleverStyle Music
 * @category    Web Components
 * @author      Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright   Copyright (c) 2014, Nazar Mokrynskyi
 * @license     MIT License, see license.txt
###

music_storage	= navigator.getDeviceStorage('music')
music_library	= cs.music_library
music_playlist	= cs.music_playlist
player			= null

Polymer(
	'cs-music-player',
	title	: 'Unknown'
	artist	: 'Unknown'
	ready	: ->
		new Blur(
			el			: @
			path		: '/web-components/cs-music-player/img/bg.jpg'
			radius		: 10
		)
	rescan	: ->
		music_library.rescan ->
			music_playlist.refresh()
			alert 'Rescanned successfully, playlist refreshed'
	play	: (id) ->
		id			= if !isNaN(parseInt(id)) then id else undefined
		element		= @
		play_button	= element.shadowRoot.querySelector('[icon=play]')
		if player && !id
			if player.playing
				player.pause()
				play_button.icon = 'play'
			else
				player.play()
				play_button.icon = 'pause'
		else if id
			music_library.get(id, (data) ->
				music_storage.get(data.name).onsuccess = ->
					player?.stop()
					player = AV.Player.fromURL(window.URL.createObjectURL(@result))
					# Change channel type to play in background
					player.on('ready', ->
						setTimeout (=>
							cover	= player.asset.metadata.coverArt?.toBlobURL() || '/web-components/cs-music-player/img/bg.jpg'
							@device.device.node.context.mozAudioChannelType						= 'content'
							element.style.backgroundImage										= "url(#{cover}"
							element.shadowRoot.querySelector('cs-cover').style.backgroundImage	= "url(#{cover}"
							new Blur(
								el			: element
								path		: cover
								radius		: 10
							)
						), 0
					)
					# Next track after end of current
					player.on('end', ->
						element.next()
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
		else
			music_playlist.current (id) =>
				@play(id)
	prev	: ->
		music_playlist.prev (id) =>
			@play(id)
	next	: ->
		music_playlist.next (id) =>
			@play(id)
)
