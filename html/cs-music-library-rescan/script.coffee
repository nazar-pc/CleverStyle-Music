###*
 * @package   CleverStyle Music
 * @category  Web Components
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2014-2015, Nazar Mokrynskyi
 * @license   MIT License, see license.txt
###

document.webL10n.ready ->
	music_playlist	= cs.music_playlist
	player			= document.querySelector('cs-music-player')

	Polymer(
		'cs-music-library-rescan'
		searching_for_music_text	: _('searching-for-music')
		files_found_text			: _('files-found')
		found						: 0
		created						: ->
			cs.bus.on('library/rescan/found', (found) =>
				@found	= found
			)
		showChanged				: ->
			if !@found && @show
				@rescan()
		rescan					: ->
			cs.music_library.rescan(=>
				music_playlist.refresh()
				alert _('library-rescanned-playlist-updated')
				@go_to_screen('player')
				setTimeout (=>
					@found	= 0
					player.next ->
						player.play()
				), 200
			)
		back						: ->
			@go_back_screen()
	)
