###*
 * @package   CleverStyle Music
 * @category  Web Components
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2014-2015, Nazar Mokrynskyi
 * @license   MIT License, see license.txt
###

$ ->
	music_playlist	= cs.music_playlist
	player			= document.querySelector('cs-music-player')

	Polymer(
		'is'		: 'cs-music-library-action'
		behaviors	: [
			Polymer.cs.behaviors.Language
			Polymer.cs.behaviors.Screen
		]
		properties	:
			items	: []
		update : (items) ->
			@set('items', items)
		create_playlist : ->
			music_playlist.set(@items, =>
				player.next =>
					@go_to_screen('player')
			)
		add_to_playlist : ->
			music_playlist.append(@items, =>
				@go_back_screen()
			)
		back : ->
			@go_back_screen()
	)
