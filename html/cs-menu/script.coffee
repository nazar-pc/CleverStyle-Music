###*
 * @package   CleverStyle Music
 * @category  Web Components
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2014-2015, Nazar Mokrynskyi
 * @license   MIT License, see license.txt
###

music_settings		= cs.music_settings
document.webL10n.ready ->
	$body			= $('body')
	Polymer(
		'cs-menu'
		playlist_text				: _('playlist')
		equalizer_text				: _('equalizer')
		sound_environment_text		: _('sound-environment')
		library_text				: _('library')
		rescan_library_text			: _('rescan-library')
		low_performance_mode_text	: _('low-performance-mode')
		low_performance				: music_settings.low_performance
		playlist				: ->
			document.querySelector('cs-music-playlist').open()
		equalizer				: ->
			document.querySelector('cs-music-equalizer').open()
			@back()
		sound_environment		: ->
			document.querySelector('cs-music-sound-environment').open()
			@back()
		library					: ->
			document.querySelector('cs-music-library').open()
		rescan					: ->
			document.querySelector('cs-music-library-rescan').open()
		performance				: ->
			if music_settings.low_performance != confirm _('low-performance-mode-details')
				music_settings.low_performance = !music_settings.low_performance
				location.reload()
		back					: ->
			$body.removeClass('menu')
	)
