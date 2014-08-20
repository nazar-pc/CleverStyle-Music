###*
 * @package     CleverStyle Music
 * @category    app
 * @author      Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright   Copyright (c) 2014, Nazar Mokrynskyi
 * @license     MIT License, see license.txt
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
	public_settings	= {}
	for option in ['repeat', 'shuffle', 'equalizer_gain_levels']
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
	public_settings
