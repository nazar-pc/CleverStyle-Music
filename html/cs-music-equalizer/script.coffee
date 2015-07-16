###*
 * @package     CleverStyle Music
 * @category    Web Components
 * @author      Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright   Copyright (c) 2014, Nazar Mokrynskyi
 * @license     MIT License, see license.txt
###

document.webL10n.ready ->
	$body					= $('body')
	sound_processing		= cs.sound_processing
	equalizer_presets		= document.querySelector('cs-music-equalizer-presets')

	Polymer(
		'cs-music-equalizer'
		gain_levels			: sound_processing.get_gain_levels()
		ready				: ->
			gain_levels	= @gain_levels
			$(@.shadowRoot.querySelectorAll('input[type=range]')).ranger(
				vertical	: true
				label		: false
				min			: -10
				max			: 10
				step		: .01
				callback	: (val) ->
					gain_levels[$(@).prev().data('index')]	= Math.round(val * 100) / 100
					sound_processing.set_gain_levels(gain_levels)
			)
		update				: (gain_levels) ->
			@gain_levels	= gain_levels
			sound_processing.set_gain_levels(gain_levels)
			setTimeout (=>
				$(@.shadowRoot.querySelectorAll('input[type=range]')).ranger('reset')
			), 100
		open				: ->
			$body.addClass('equalizer')
		equalizer_presets	: ->
			equalizer_presets.open()
		back				: ->
			$body.removeClass('equalizer')
	)
