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
	'cs-menu'
	rescan	: ->
		music_library.rescan ->
			music_playlist.refresh()
			alert 'Rescanned successfully, playlist refreshed'
	playlist	: ->
		$body	= $(body)
		$body.removeClass('menu')
		setTimeout (->
			$body.addClass('playlist')
			setTimeout (->
				document.querySelector('cs-music-playlist').refresh()
			), 200
		), 200
	back	: ->
		$(body).removeClass('menu')
)
