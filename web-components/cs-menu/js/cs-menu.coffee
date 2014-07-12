###*
 * @package     CleverStyle Music
 * @category    Web Components
 * @author      Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright   Copyright (c) 2014, Nazar Mokrynskyi
 * @license     MIT License, see license.txt
###

music_library	= cs.music_library
music_playlist	= cs.music_playlist
Polymer(
	'cs-menu'
	ready	: ->
		setTimeout (=>
			@style.display	= 'block'
		), 500
	rescan	: ->
		music_library.rescan ->
			music_playlist.refresh()
			alert 'Rescanned successfully, playlist refreshed'
	back	: ->
		$(@).css(
			marginLeft	: '-100vw'
		)
		$('cs-music-player').css(
			marginLeft	: 0
		)
)
