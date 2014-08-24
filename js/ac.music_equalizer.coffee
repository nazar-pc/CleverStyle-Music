###*
 * @package     CleverStyle Music
 * @category    app
 * @author      Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright   Copyright (c) 2014, Nazar Mokrynskyi
 * @license     MIT License, see license.txt
###
window.AudioContext	= AudioContext || webkitAudioContext
music_settings		= cs.music_settings

cs.music_equalizer	= do ->
	frequencies_to_control	= [32, 64, 125, 250, 500, 1000, 2000, 4000, 8000, 16000] #kHz
	frequencies_types		= ['lowshelf', 'lowshelf', 'lowshelf', 'peaking', 'peaking', 'peaking', 'peaking', 'highshelf', 'highshelf', 'highshelf']
	gain_levels				= music_settings.equalizer_gain_levels || [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	create_equalizer		= (audio) ->
		context				= audio.context
		source				= audio.source
		frequencies			= []
		audio.frequencies	= frequencies
		for frequency, index in frequencies_to_control
			frequencies[index]					= context.createBiquadFilter()
			frequencies[index].frequency.value	= frequency
			frequencies[index].type				= frequencies_types[index]
			frequencies[index].gain.value		= gain_levels[index]
			frequencies[index].Q.value			= 1
			source.connect(frequencies[index])
			source								= frequencies[index]
		source
	update_equalizer		= (audio) ->
		frequencies	= audio.frequencies
		for frequency, index in frequencies_to_control
			frequencies[index].gain.value	= gain_levels[index]
		return

	add_to_element	: (element) ->
		audio								= {}
		element.audio_processing			= audio
		audio.context						= new AudioContext
		audio.context.mozAudioChannelType	= 'content'
		audio.source						= audio.context.createMediaElementSource(element)
		audio.source						= create_equalizer(audio)
		audio.source.connect(audio.context.destination)
	update				: (element) ->
		audio	= element.audio_processing
		update_equalizer(audio)
	get_gain_levels		: ->
		gain_levels
	set_gain_levels		: (new_gain_levels) ->
		gain_levels								= new_gain_levels
		music_settings.equalizer_gain_levels	= new_gain_levels
		cs.bus.trigger('equalizer/update')
