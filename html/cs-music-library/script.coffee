###*
 * @package   CleverStyle Music
 * @category  Web Components
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2014-2015, Nazar Mokrynskyi
 * @license   MIT License, see license.txt
###

$ ->
	music_library			= cs.music_library
	music_playlist			= cs.music_playlist
	player					= document.querySelector('cs-music-player')
	music_library_grouped	= document.querySelector('cs-music-library-grouped')

	Polymer(
		'is'		: 'cs-music-library'
		behaviors	: [
			Polymer.cs.behaviors.Language
			Polymer.cs.behaviors.Screen
		]
		properties	:
			loading	: false
		group : (e) ->
			group_field		= e.originalTarget.dataset.groupField
			music_library.get_all (all) =>
				for value, i in all
					all[i] = value.id
				switch group_field
					when 'artist', 'album', 'genre', 'year', 'rated'
						music_library_grouped.update(group_field, all)
						@go_to_screen('library-grouped')
					else
						@loading	= true
						music_playlist.set(all, =>
							player.next =>
								@go_to_screen('player')
								@loading	= false
						)
		back : ->
			@go_back_screen()
	)
