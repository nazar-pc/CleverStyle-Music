###*
 * @package   CleverStyle Music
 * @category  Web Components
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2014-2015, Nazar Mokrynskyi
 * @license   MIT License, see license.txt
###

music_settings	= cs.music_settings
$ ->
	Polymer(
		'is'						: 'cs-music-menu'
		behaviors					: [cs.behaviors.Screen]
		playlist_text				: _('playlist')
		equalizer_text				: _('equalizer')
		sound_environment_text		: _('sound-environment')
		library_text				: _('library')
		rescan_library_text			: _('rescan-library')
		low_performance_mode_text	: _('low-performance-mode')
		low_performance				: music_settings.low_performance
		playlist				: ->
			@go_to_screen('playlist')
		equalizer				: ->
			@go_to_screen('equalizer')
		sound_environment		: ->
			@go_to_screen('sound-environment')
		library					: ->
			@go_to_screen('library')
		rescan					: ->
			@go_to_screen('library-rescan')
		performance				: ->
			if music_settings.low_performance != confirm _('low-performance-mode-details')
				music_settings.low_performance = !music_settings.low_performance
				location.reload()
		back					: ->
			@go_to_screen('player')
	)
