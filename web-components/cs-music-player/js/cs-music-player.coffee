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
seeking_bar		= null
#file_to_play	= null

Polymer(
	'cs-music-player'
	title				: ''
	artist				: ''
	ready	: ->
		seeking_bar	= @shadowRoot.querySelector('cs-seeking-bar')
		@player		= do =>
			player_element						= document.createElement('audio')
			# Change channel type to play in background
			player_element.mozAudioChannelType	= 'content'
			object_url							= null
			player_element.addEventListener('loadeddata', ->
				URL.revokeObjectURL(object_url)
				object_url	= null
			)
			player_element.addEventListener('error', =>
				@player.pause()
			)
			player_element.addEventListener('ended', =>
				@next()
			)
			player_element.addEventListener('timeupdate', =>
				current_time	= player_element.currentTime
				duration		= player_element.duration
				time_format		= (time) ->
					min	= Math.floor(time / 60)
					sec	= Math.floor(time % 60)
					if min < 10
						min = "0#{min}"
					if sec < 10
						sec = "0#{sec}"
					min + ':' + sec
				seeking_bar.current_time		= time_format(current_time)
				seeking_bar.duration			= if duration then time_format(duration) else '00:00'
				seeking_bar.progress_percentage	= if duration then Math.floor(current_time / duration* 10000) / 100 else 0
			)
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
		@play(null, =>
			@play()
			@player.currentTime = 0
		)
	play	: (id, callback) ->
		id			= if !isNaN(parseInt(id)) then id else undefined
		if typeof callback != 'function'
			callback	= ->
		else
			callback.bind(@)
		element		= @
		play_button	= element.shadowRoot.querySelector('[icon=play]')
		if @player.file_loaded && !id
			if @player.playing
				@player.pause()
				play_button.icon = 'play'
			else
				@player.play()
				play_button.icon = 'pause'
		else if id
			music_library.get(id, (data) ->
				get_file	= music_storage.get(data.name)
				get_file.onsuccess = ->
					blob			= @result
#					file_to_play	= URL.createObjectURL(@result)
					element.player.open_new_file(blob)
					#player			= AV.Player.fromURL(file_to_play)
					# Change channel type to play in background
					do ->
						update_cover									= (cover) ->
							element.shadowRoot.querySelector('cs-cover').style.backgroundImage	= if cover then "url(#{cover})" else 'none'
							cover_bg															= cover || 'img/bg.jpg'
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
							body.backgroundImage												= "url(img/bg.jpg)"
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
					callback()
				get_file.onerror = (e) ->
					alert "Can't play this file: #{e.target.error.name}"
			)
		else
			music_playlist.current (id) =>
				@play(id, callback)
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
