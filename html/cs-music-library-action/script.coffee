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
		'is'					: 'cs-music-library-action'
		behaviors				: [cs.behaviors.Screen]
		create_playlist_text	: _('create-playlist')
		add_to_playlist_text	: _('add-to-playlist')
		items					: []
		update					: (items) ->
			@items	= items
		create_playlist			: ->
			music_playlist.set(@items, =>
				player.next =>
					@go_to_screen('player')
			)
		add_to_playlist			: ->
			music_playlist.append(@items, =>
				@go_back_screen()
			)
		back			: ->
			@go_back_screen()
	)
