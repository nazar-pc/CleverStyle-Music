###*
 * @package   CleverStyle Music
 * @category  Web Components
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2014-2015, Nazar Mokrynskyi
 * @license   MIT License, see license.txt
###

$ ->
	sound_processing	= cs.sound_processing

	Polymer(
		'is'				: 'cs-music-equalizer'
		behaviors			: [Polymer.cs.behaviors.Screen]
		properties:
			gain_levels	: sound_processing.get_gain_levels()
		ready				: ->
			gain_levels	= @gain_levels
			$inputs		= $(@shadowRoot.querySelectorAll('input[type=range]'))
			that		= @
			$inputs.ranger(
				vertical	: true
				label		: false
				min			: -10
				max			: 10
				step		: .01
				callback	: (val) ->
					index				= $(@).prev().data('index')
					gain_levels[index]	= Math.round(val * 100) / 100
					# Hack: normal changing without slice or changing just one item doesn't work unfortunately
					that.set('gain_levels', gain_levels.slice())
					sound_processing.set_gain_levels(gain_levels)
			)
			# Fix styling for ranger since it was created without Polymer awareness
			@scopeSubtree(@$.levels, false)
			# Force track height recalculation
			$inputs.ranger('reset')
		update				: (gain_levels) ->
			@set('gain_levels', gain_levels)
			sound_processing.set_gain_levels(gain_levels)
			setTimeout (=>
				$(@shadowRoot.querySelectorAll('input[type=range]')).ranger('reset')
			), 100
		equalizer_presets	: ->
			@go_to_screen('equalizer-presets')
		back				: ->
			@go_back_screen()
	)
