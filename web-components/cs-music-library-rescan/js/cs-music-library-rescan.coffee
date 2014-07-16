###*
 * @package     CleverStyle Music
 * @category    Web Components
 * @author      Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright   Copyright (c) 2014, Nazar Mokrynskyi
 * @license     MIT License, see license.txt
###

music_library	= cs.music_library
music_playlist	= cs.music_playlist
$body			= $(document.querySelector('body'))
player			= document.querySelector('cs-music-player')

Polymer(
	'cs-music-library-rescan'
	created	: ->
		cs.bus.on('library/rescan/found', (found) =>
			@found	= found
		)
	found	: 0
	open	: ->
		if !@found
			cs.music_library.rescan(=>
				music_playlist.refresh()
				alert 'Library updated, playlist updated'
				@back()
				setTimeout (->
					@found	= 0
					player.next ->
						player.play()
				), 400
			)
	back	: ->
		$body.removeClass('library-rescan')
		setTimeout (->
			$body.removeClass('menu')
		), 200
)
