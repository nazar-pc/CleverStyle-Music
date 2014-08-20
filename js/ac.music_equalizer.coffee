###*
 * @package     CleverStyle Music
 * @category    app
 * @author      Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright   Copyright (c) 2014, Nazar Mokrynskyi
 * @license     MIT License, see license.txt
###
music_settings	= cs.music_settings

cs.music_equalizer	= do ->
	frequencies_to_control	= [32, 64, 125, 250, 500, 1000, 2000, 4000, 8000, 16000] #kHz
	frequencies_types		= ['lowshelf', 'lowshelf', 'lowshelf', 'peaking', 'peaking', 'peaking', 'peaking', 'highshelf', 'highshelf', 'highshelf']
	gain_levels				= music_settings.equalizer_gain_levels || [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

	add_to_element	: (element) ->
		audioContext						= new AudioContext
		audioContext.mozAudioChannelType	= 'content'
		audioSource							= audioContext.createMediaElementSource(element)
		frequencies		= []
		for frequency, index in frequencies_to_control
			frequencies[index]	= audioContext.createBiquadFilter()
			frequencies[index].frequency.value	= frequency
			frequencies[index].type				= frequencies_types[index]
			frequencies[index].gain.value		= gain_levels[index]
			frequencies[index].Q.value			= 1
			if index == 0
				if element.equalizer_audio_source
					element.equalizer_audio_source.disconnect()
				element.equalizer_audio_source	= audioSource
				audioSource.connect(frequencies[index])
			else
				frequencies[index - 1].connect(frequencies[index])
				if index == frequencies_to_control.length - 1
					frequencies[index].connect(audioContext.destination)
	set_gain_levels		: (new_gain_levels) ->
		gain_levels								= new_gain_levels
		music_settings.equalizer_gain_levels	= new_gain_levels
		cs.bus.trigger('equalizer/update')
