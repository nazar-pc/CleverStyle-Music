###*
 * @package     CleverStyle Music
 * @category    Web Components
 * @author      Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright   Copyright (c) 2014, Nazar Mokrynskyi
 * @license     MIT License, see license.txt
###

document.webL10n.ready ->
	$body					= $('body')
	music_equalizer			= cs.music_equalizer
	equalizer_presets		= document.querySelector('cs-music-equalizer-presets')

	Polymer(
		'cs-music-equalizer'
		gain_levels			: music_equalizer.get_gain_levels()
		ready				: ->
			gain_levels	= @gain_levels
			$(@.shadowRoot.querySelectorAll('input[type=range]')).ranger(
				vertical	: true
				label		: false
				min			: -20
				max			: 20
				step		: .01
				callback	: (val) ->
					gain_levels[$(@).prev().data('index')]	= Math.round(val * 100) / 100
					music_equalizer.set_gain_levels(gain_levels)
			)
		update				: (gain_levels) ->
			$(@.shadowRoot.querySelectorAll('input[type=range]')).ranger('destroy')
			@gain_levels	= gain_levels
			music_equalizer.set_gain_levels(gain_levels)
			setTimeout (=>
				@ready()
			), 100
		open				: ->
			$body.addClass('equalizer')
		equalizer_presets	: ->
			equalizer_presets.open()
		back				: ->
			$body.removeClass('equalizer')
	)
