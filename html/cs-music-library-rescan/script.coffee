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
		'is'		: 'cs-music-library-rescan'
		behaviors	: [
			Polymer.cs.behaviors.Language
			Polymer.cs.behaviors.Screen
		]
		properties	:
			found	: 0
		created : ->
			cs.bus.on('library/rescan/found', (found) =>
				@found	= found
			)
		showChanged : ->
			if !@found && @show
				@rescan()
		rescan : ->
			cs.music_library.rescan(=>
				music_playlist
					.clear()
					.refresh()
				alert __('library-rescanned-playlist-updated')
				$(player).one('animationend', ->
					player.next((->), true)
				)
				@go_to_screen('player')
				# Some events might be stuck at the moment and thus they'll override zero here, so better add event firing here
				cs.bus.fire('library/rescan/found', 0)
			)
		back : ->
			@go_back_screen()
	)
