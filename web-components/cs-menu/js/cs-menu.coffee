###*
 * @package     CleverStyle Music
 * @category    Web Components
 * @author      Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright   Copyright (c) 2014, Nazar Mokrynskyi
 * @license     MIT License, see license.txt
###

document.webL10n.ready ->
	$body			= $(document.querySelector('body'))

	Polymer(
		'cs-menu'
		playlist_text		: _('playlist')
		library_text		: _('library')
		rescan_library_text	: _('rescan-library')
		playlist			: ->
			$body.addClass('playlist')
			setTimeout (->
				document.querySelector('cs-music-playlist').open()
			), 200
		library				: ->
			$body.addClass('library')
			setTimeout (->
				document.querySelector('cs-library').open()
			), 200
		rescan				: ->
			$body.addClass('library-rescan')
			setTimeout (->
				document.querySelector('cs-music-library-rescan').open()
			), 200
		back				: ->
			$body.removeClass('menu')
	)
