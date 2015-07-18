###*
 * @package   CleverStyle Music
 * @category  app
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2014-2015, Nazar Mokrynskyi
 * @license   MIT License, see license.txt
###
cs.music_settings	= do ->
	settings		= localStorage.settings
	settings		=
		if settings
			JSON.parse(settings)
		else
			repeat					: 'all'
			shuffle					: true
			equalizer_gain_levels	: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
			reverb_mode				: ''
			low_performance			: null
	public_settings	= {}
	for option in ['repeat', 'shuffle', 'equalizer_gain_levels', 'reverb_mode', 'low_performance']
		do (option = option) ->
			Object.defineProperty(
				public_settings
				option
				get	: ->
					settings[option]
				set	: (value) ->
					settings[option]		= value
					localStorage.settings	= JSON.stringify(settings)
			)
	if public_settings.low_performance == null
		$ ->
			public_settings.low_performance = confirm _('low-performance-mode-details')
			location.reload()
	if public_settings.low_performance
		$ ->
			$('body').addClass('low-performance')
	public_settings
