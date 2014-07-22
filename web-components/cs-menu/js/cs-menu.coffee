###*
 * @package     CleverStyle Music
 * @category    Web Components
 * @author      Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright   Copyright (c) 2014, Nazar Mokrynskyi
 * @license     MIT License, see license.txt
###

document.webL10n.ready ->
	music_library	= cs.music_library
	music_playlist	= cs.music_playlist
	$body			= $(document.querySelector('body'))

	Polymer(
		'cs-menu'
		rescan_library_text	: _('rescan-library')
		playlist_text		: _('playlist')
		rescan				: ->
			$body.addClass('library-rescan')
			setTimeout (->
				document.querySelector('cs-music-library-rescan').open()
			), 200
		playlist			: ->
			$body.removeClass('menu')
			setTimeout (->
				$body.addClass('playlist')
				setTimeout (->
					document.querySelector('cs-music-playlist').open()
				), 200
			), 200
		back				: ->
			$body.removeClass('menu')
	)
