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
body			= document.querySelector('body')
player			= do ->
	player_element						= document.createElement('audio')
	# Change channel type to play in background
	player_element.mozAudioChannelType	= 'content'
	object_url							= null
	player_element.addEventListener('loadeddata', ->
		URL.revokeObjectURL(object_url)
		object_url	= null
	)
	player_element.addEventListener('error', ->
		player.pause()
	)
	window.player_element				= player_element
	return {
		open_new_file	: (blob) ->
			if this.playing
				@pause()
			if object_url
				URL.revokeObjectURL(object_url)
			object_url			= URL.createObjectURL(blob)
			player_element.src	= object_url
			player_element.load()
			this.file_loaded	= true
			player_element.play()
			this.playing	= true
		play			: ->
			player_element.play()
			this.playing	= true
		pause			: ->
			player_element.pause()
			this.playing	= false
	}
#file_to_play	= null

Polymer(
	'cs-music-player'
	title	: 'Unknown'
	artist	: 'Unknown'
	play	: (id) ->
		id			= if !isNaN(parseInt(id)) then id else undefined
		element		= @
		play_button	= element.shadowRoot.querySelector('[icon=play]')
		if player.file_loaded && !id
			if player.playing
				player.pause()
				play_button.icon = 'play'
			else
				player.play()
				play_button.icon = 'pause'
		else if id
			music_library.get(id, (data) ->
				music_storage.get(data.name).onsuccess = ->
					blob			= @result
#					file_to_play	= URL.createObjectURL(@result)
					player.open_new_file(blob)
					#player			= AV.Player.fromURL(file_to_play)
					# Change channel type to play in background
					do ->
						update_cover									= (cover) ->
							element.shadowRoot.querySelector('cs-cover').style.backgroundImage	= if cover then "url(#{cover})" else 'none'
							cover_bg															= cover || '/web-components/cs-music-player/img/bg.jpg'
							body.style.backgroundImage											= "url(#{cover_bg})"
							if cover
								new Blur(
									el			: body
									path		: cover
									radius		: 10
								)
							setTimeout (->
								URL.revokeObjectURL(cover)
							), 500
						update_cover_timeout = setTimeout (->
							element.shadowRoot.querySelector('cs-cover').style.backgroundImage	= 'none'
							body.backgroundImage												= "url(/web-components/cs-music-player/img/bg.jpg)"
						), 500
						parseAudioMetadata(
							blob
							(metadata) ->
								clearInterval(update_cover_timeout)
								cover	= metadata.picture
								if cover
									cover	= URL.createObjectURL(cover)
								update_cover(cover)
						)
#					player.on('ready', ->
#						@device.device.node.context.mozAudioChannelType	= 'content'
#						if data.name.substr(-4) != '.mp3'
#							setTimeout (->
#								update_cover(player.asset.metadata.coverArt?.toBlobURL())
#							), 0
#					)
#					# Next track after end of current
#					player.on('end', ->
#						element.next()
#					)
#					player.play()
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
	menu	: ->
		$(@).css(
			marginLeft	: '100vw'
		)
		$('cs-menu').css(
			marginLeft	: 0
		)
)
