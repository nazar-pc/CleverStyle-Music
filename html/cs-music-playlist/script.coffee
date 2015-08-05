###*
 * @package   CleverStyle Music
 * @category  Web Components
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2014-2015, Nazar Mokrynskyi
 * @license   MIT License, see license.txt
###

$ ->
	music_library	= cs.music_library
	music_playlist	= cs.music_playlist
	music_settings	= cs.music_settings
	player			= document.querySelector('cs-music-player')
	scroll_interval	= 0

	Polymer(
		'is'			: 'cs-music-playlist'
		behaviors		: [cs.behaviors.Screen]
		properties		:
			list	:
				type	: Array
				value	: []
		created			: ->
			cs.bus
				.on('player/play', (id) =>
					if @list.length
						@update_status(id)
				)
				.on('player/pause', =>
					if @list.length
						@update_status()
				)
				.on('player/resume', =>
					if @list.length
						@update_status()
				)
		ready			: ->
			switch music_settings.repeat
				when 'none'
					@.shadowRoot.querySelector('[icon=repeat]').setAttribute('disabled', '')
				when 'one'
					@.shadowRoot.querySelector('[icon=repeat]').innerHTML	= 1
			if !music_settings.shuffle
				@.shadowRoot.querySelector('[icon=random]').setAttribute('disabled', '')
		showChanged		: ->
			if @show
				@update()
		update			: ->
			music_playlist.current (current_id) =>
				music_playlist.get_all (all) =>
					index			= 0
					list			= []
					count			= all.length
					get_next_item	= =>
						if index < count
							music_library.get_meta(all[index], (data) =>
								data.playing		= data.id == current_id
								data.icon			= if cs.bus.state.player == 'playing' then 'play' else 'pause'
								data.artist_title	= []
								if data.artist
									data.artist_title.push(data.artist)
								if data.title
									data.artist_title.push(data.title)
								data.artist_title	= data.artist_title.join(' — ') || _('unknown')
								list.push(data)
								data	= null
								++index
								get_next_item()
							)
						else if @show
							@list			= list
							scroll_interval	= setInterval (=>
								items_container	= @shadowRoot.querySelector('cs-music-playlist-items')
								if items_container
									item			= items_container.querySelector('cs-music-playlist-item[playing]')
									clearInterval(scroll_interval)
									scroll_interval				= 0
									items_container.scrollTop	= item.offsetTop
							), 100
					get_next_item()
		play			: (e) ->
			music_playlist.current (old_id) =>
				music_playlist.set_current(
					e.target.dataset.index
				)
				music_playlist.current (id) =>
					if id != old_id
						player.play(id)
					else
						player.play()
		update_status	: (new_id) ->
			@list.forEach (data, index) =>
				if (
					data.id == new_id ||
					(
						data.playing && !new_id
					)
				)
					data.playing	= true
					data.icon		= if cs.bus.state.player == 'playing' then 'play' else 'pause'
#					@splice('list', index, 1, data)
					#Hack: ugly manual notification because Polymer is not smart enough at the moment to do that in one line
					@notifyPath('list.' + index + '.playing', data.playing)
					@notifyPath('list.' + index + '.icon', data.icon)
				else if data.playing
					data.playing	= false
					delete data.icon
#					@splice('list', index, 1, data)
					#Hack: ugly manual notification because Polymer is not smart enough at the moment to do that in one line
					@notifyPath('list.' + index + '.playing', data.playing)
					@notifyPath('list.' + index + '.icon', data.icon)
		back			: ->
			@go_back_screen()
			requestAnimationFrame =>
				@list = []
				if scroll_interval
					clearInterval(scroll_interval)
					scroll_interval	= 0
		repeat			: (e) ->
			control					= e.target
			music_settings.repeat	=
				switch music_settings.repeat
					when 'none' then 'all'
					when 'all' then 'one'
					when 'one' then 'none'
			if music_settings.repeat == 'none'
				control.setAttribute('disabled', '')
			else
				control.removeAttribute('disabled')
			control.innerHTML	= if music_settings.repeat == 'one' then 1 else ''
		shuffle			: (e) ->
			control					= e.target
			music_settings.shuffle	= !music_settings.shuffle
			if !music_settings.shuffle
				control.setAttribute('disabled', '')
			else
				control.removeAttribute('disabled')
			@list	= []
			music_playlist.current (id) =>
				music_playlist.refresh =>
					music_playlist.set_current_id(id)
					@update()
		icon_class		: (icon) ->
			"fa fa-#{icon}"
	)
