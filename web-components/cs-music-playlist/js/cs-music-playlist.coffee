###*
 * @package     CleverStyle Music
 * @category    Web Components
 * @author      Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright   Copyright (c) 2014, Nazar Mokrynskyi
 * @license     MIT License, see license.txt
###

music_library	= cs.music_library
music_playlist	= cs.music_playlist
body			= document.querySelector('body')
player			= document.querySelector('cs-music-player')
scroll_interval	= 0

Polymer(
	'cs-music-playlist'
	created	: ->
		cs.bus.on('player/play', (id) =>
			if @list.length
				@update(id)
		)
	list	: []
	open	: ->
		music_playlist.current (current_id) =>
			music_playlist.get_all (all) =>
				index			= 0
				list			= []
				count			= all.length
				get_next_item	= =>
					if index < count
						music_library.get_meta(all[index], (data) =>
							data.playing	= if data.id == current_id then 'yes' else 'no'
							data.icon		= if cs.bus.state.player == 'playing' then 'play' else 'pause'
							list.push(data)
							++index
							get_next_item()
						)
					else
						@list			= list
						scroll_interval	= setInterval (=>
							items_container	= @shadowRoot.querySelector('cs-playlist-items')
							if items_container
								item			= items_container.querySelector('cs-playlist-item[playing=yes]')
								clearInterval(scroll_interval)
								scroll_interval				= 0
								items_container.scrollTop	= item.offsetTop
						), 100
				get_next_item()
	play	: (e) ->
		music_playlist.current (old_id) =>
			music_playlist.set_current(
				e.impl.target.dataset.index
			)
			music_playlist.current (id) =>
				if id != old_id
					player.play(id)
					@update(id)
				else
					player.play()
					@update(id)
	update	: (new_id) ->
		@list.forEach (data, index) =>
			if data.id == new_id
				@list[index].playing	= 'yes'
				@list[index].icon		= if cs.bus.state.player == 'playing' then 'play' else 'pause'
			else
				@list[index].playing = 'no'
				delete @list[index].icon
	back	: ->
		$(body).removeClass('playlist')
		setTimeout (=>
			@list = []
			if scroll_interval
				clearInterval(scroll_interval)
				scroll_interval	= 0
		), 500
)
