###*
 * @package     CleverStyle Music
 * @category    Web Components
 * @author      Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright   Copyright (c) 2014, Nazar Mokrynskyi
 * @license     MIT License, see license.txt
###

document.webL10n.ready ->
	$body			= $('body')

	Polymer(
		'cs-menu'
		playlist_text		: _('playlist')
		library_text		: _('library')
		rescan_library_text	: _('rescan-library')
		playlist			: ->
			document.querySelector('cs-music-playlist').open()
		library				: ->
			document.querySelector('cs-music-library').open()
		rescan				: ->
			document.querySelector('cs-music-library-rescan').open()
		back				: ->
			$body.removeClass('menu')
	)
