###*
 * @package     CleverStyle Music
 * @category    Web Components
 * @author      Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright   Copyright (c) 2014, Nazar Mokrynskyi
 * @license     MIT License, see license.txt
###

music_storage	= navigator.getDeviceStorage('music')
music_equalizer	= cs.music_equalizer
music_library	= cs.music_library
music_playlist	= cs.music_playlist
music_settings	= cs.music_settings
body			= document.querySelector('body')
seeking_bar		= null

Polymer(
	'cs-music-player'
	title				: ''
	artist				: ''
	ready	: ->
		seeking_bar	= @shadowRoot.querySelector('cs-seeking-bar')
		$(seeking_bar).on('seeking-update', (e, data) =>
			@seeking(data.percents)
		)
		@player		= do =>
			player_element						= document.createElement('audio')
			music_equalizer.add_to_element(player_element.impl)
			cs.bus.on('equalizer/update', ->
				music_equalizer.add_to_element(player_element.impl)
				# TODO: uncomment when equalizer will be able to deal with aurora.js
#				if aurora_player
#					music_equalizer.add_to_element(aurora_player.device.device.node)
			)
			aurora_player						= null
			playing_started						= 0
			# Change channel type to play in background
			player_element.mozAudioChannelType	= 'content'
			object_url							= null
			player_element.addEventListener('loadeddata', ->
				URL.revokeObjectURL(object_url)
				object_url	= null
			)
			player_element.addEventListener('error', =>
				if new Date - playing_started > 1000
					@player.pause()
				else
					play_with_aurora()
			)
			player_element.addEventListener('ended', =>
				# Pause
				@play()
				switch music_settings.repeat
					when 'one'
						music_playlist.current (id) =>
							@play(id)
					else
						@next()
			)
			player_element.addEventListener('timeupdate', =>
				current_time					= player_element.currentTime
				duration						= player_element.duration
				seeking_bar.current_time		= time_format(current_time)
				seeking_bar.duration			= if duration then time_format(duration) else '00:00'
				seeking_bar.progress_percentage	= if duration then current_time / duration * 100 else 0
			)
			play_with_aurora	= =>
				aurora_player	= AV.Player.fromURL(object_url)
				aurora_player.on('ready', ->
					@device.device.node.context.mozAudioChannelType	= 'content'
					# TODO: uncomment when equalizer will be able to deal with aurora.js
#					music_equalizer.add_to_element(@device.device.node)
				)
				aurora_player.on('end', =>
					# Pause
					@play()
					switch music_settings.repeat
						when 'one'
							music_playlist.current (id) =>
								@play(id)
						else
							@next()
				)
				aurora_player.on('duration', (duration) ->
					duration	/= 1000
					aurora_player.on('progress', ->
						current_time					= aurora_player.currentTime / 1000
						seeking_bar.current_time		= time_format(current_time)
						seeking_bar.duration			= if duration then time_format(duration) else '00:00'
						seeking_bar.progress_percentage	= if duration then current_time / duration * 100 else 0
					)
				)
				aurora_player.play()
			return {
				open_new_file	: (blob, filename) ->
					playing_started	= new Date
					if @playing
						@pause()
					if aurora_player
						aurora_player.stop()
						aurora_player	= null
					if object_url
						URL.revokeObjectURL(object_url)
					object_url			= URL.createObjectURL(blob)
					if filename.substr(0, -4) == 'alac'
						play_with_aurora()
					else
						player_element.src	= object_url
						player_element.load()
						this.file_loaded	= true
						player_element.play()
						@playing		= true
				play			: ->
					playing_started	= new Date
					if	aurora_player
						aurora_player.play()
					else
						player_element.play()
					@playing	= true
				pause			: ->
					if aurora_player
						aurora_player.pause()
					else
						player_element.pause()
					@playing	= false
				seeking			: (percents) =>
					if aurora_player
						aurora_player.seek(aurora_player.duration * percents / 100)
					else if player_element.duration
						player_element.pause()
						player_element.currentTime	= player_element.duration * percents / 100
						if cs.bus.state.player == 'playing'
							player_element.play()
						else
							@play()
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
				cs.bus.trigger('player/pause')
				cs.bus.state.player	= 'paused'
			else
				@player.play()
				play_button.icon = 'pause'
				cs.bus.trigger('player/resume')
				cs.bus.state.player	= 'playing'
		else if id
			music_library.get(id, (data) ->
				get_file	= music_storage.get(data.name)
				get_file.onsuccess = ->
					blob			= @result
					element.player.open_new_file(blob, data.name)
					do ->
						update_cover									= (cover) ->
							element.shadowRoot.querySelector('cs-cover').style.backgroundImage	= if cover then "url(#{cover})" else 'none'
							if cover
								el							= document.createElement('div')
								el.style.backgroundImage	= "url(#{cover})"
								new Blur(
									el			: el
									path		: cover
									radius		: 20
									callback	: ->
										body.style.backgroundImage	= el.style.backgroundImage
										setTimeout (->
											URL.revokeObjectURL(cover)
										), 500
								)
							else
								body.style.backgroundImage	= 'url(img/bg.jpg)'
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
					play_button.icon = 'pause'
					cs.bus.trigger('player/play', id)
					cs.bus.state.player	= 'playing'
					music_library.get_meta(id, (data) ->
						if data
							element.title	= data.title || _('unknown')
							element.artist	= data.artist
							if data.artist && data.album
								element.artist += ": #{data.album}"
						else
							element.title	= _('unknown')
							element.artist	= ''
					)
					callback()
				get_file.onerror = (e) ->
					alert _(
						'cant-play-this-file'
						error	: e.target.error.name
					)
			)
		else
			music_playlist.current (id) =>
				@play(id, callback)
	prev	: (callback) ->
		music_playlist.prev (id) =>
			@play(id, callback)
	next	: (callback) ->
		music_playlist.next (id) =>
			@play(id, callback)
	menu	: ->
		$(body).addClass('menu')
	seeking	: (percents) ->
		@player.seeking(percents)
)
