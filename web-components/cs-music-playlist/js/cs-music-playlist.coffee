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

Polymer(
	'cs-music-playlist'
	list	: []
	refresh	: ->
		music_playlist.current (current_id) =>
			music_playlist.get_all (all) =>
				index			= 0
				list			= []
				count			= all.length
				get_next_item	= =>
					if index < count
						music_library.get_meta(all[index], (data) =>
							data.playing	= if data.id == current_id then 'yes' else 'no'
							list.push(data)
							++index
							get_next_item()
						)
					else
						@list	= list
				get_next_item()
	play	: (e) ->
		music_playlist.current (old_id) =>
			music_playlist.set_current(
				e.impl.target.dataset.index
			)
			music_playlist.current (id) =>
				if id != old_id
					@list.forEach (data, index) =>
						if data.id == old_id
							@list[index].playing = 'no'
						else if data.id == id
							@list[index].playing = 'yes'
					document.querySelector('cs-music-player').play(id)
				else
					@list = []
					setTimeout (->
						$(body).removeClass('playlist')
					), 200
)
