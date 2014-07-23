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
			repeat	: 'all'
			shuffle	: true
	public_settings	= {}
	for option of settings
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
