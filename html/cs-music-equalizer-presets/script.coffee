###*
 * @package   CleverStyle Music
 * @category  Web Components
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2014-2015, Nazar Mokrynskyi
 * @license   MIT License, see license.txt
###

$ ->
	equalizer										= document.querySelector('cs-music-equalizer')
	known_presets									= {}
	known_presets[__('reset')]						= [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	known_presets['Classical']						= [0, 0, 0, 0, 0, 0, -4.32, -4.32, -4.32, -5.76]
	known_presets['Club']							= [0, 0, 4.8, 3.36, 3.36, 3.36, 1.92, 0, 0, 0]
	known_presets['Dance']							= [5.76, 4.32, 1.44, 0, 0, -3.36, -4.32, -4.32, 0, 0]
	known_presets['Full Bass']						= [4.8, 5.76, 5.76, 3.36, 0.96, -2.4, -4.8, -6.24, -6.72, -6.72]
	known_presets['Full Bass & Treble']				= [4.32, 3.36, 0, -4.32, -2.88, 0.96, 4.8, 6.72, 7.2, 7.2]
	known_presets['Full Treble']					= [-5.76, -5.76, -5.76, -2.4, 1.44, 6.72, 9.6, 9.6, 9.6, 10]
	known_presets['Laptop Speakers / Headphones']	= [2.88, 6.72, 3.36, -1.92, -1.44, 0.96, 2.88, 5.76, 7.68, 8.64]
	known_presets['Large Hall']						= [6.24, 6.24, 3.36, 3.36, 0, -2.88, -2.88, -2.88, 0, 0]
	known_presets['Live']							= [-2.88, 0, 2.4, 3.36, 3.36, 3.36, 2.4, 1.44, 1.44, 1.44]
	known_presets['Party']							= [4.32, 4.32, 0, 0, 0, 0, 0, 0, 4.32, 4.32]
	known_presets['Pop']							= [-0.96, 2.88, 4.32, 4.8, 3.36, 0, -1.44, -1.44, -0.96, -0.96]
	known_presets['Reggae']							= [0, 0, 0, -3.36, 0, 3.84, 3.84, 0, 0, 0]
	known_presets['Rock']							= [4.8, 2.88, -3.36, -4.8, -1.92, 2.4, 5.28, 6.72, 6.72, 6.72]
	known_presets['Ska']							= [-1.44, -2.88, -2.4, 0, 2.4, 3.36, 5.28, 5.76, 6.72, 5.76]
	known_presets['Soft']							= [2.88, 0.96, 0, -1.44, 0, 2.4, 4.8, 5.76, 6.72, 7.2]
	known_presets['Soft rock']						= [2.4, 2.4, 1.44, 0, -2.4, -3.36, -1.92, 0, 1.44, 5.28]
	known_presets['Techno']							= [4.8, 3.36, 0, -3.36, -2.88, 0, 4.8, 5.76, 5.76, 5.28]

	Polymer(
		'is'			: 'cs-music-equalizer-presets'
		behaviors		: [Polymer.cs.behaviors.Screen]
		properties:
			presets_names	:
				for preset of known_presets
					preset
		load_preset			: (e) ->
			equalizer.update(known_presets[e.model.preset])
		back			: ->
			@go_back_screen()
	)
