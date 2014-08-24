###*
 * @package     CleverStyle Music
 * @category    app
 * @author      Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright   Copyright (c) 2014, Nazar Mokrynskyi
 * @license     MIT License, see license.txt
###
window.AudioContext	= AudioContext || webkitAudioContext
music_settings		= cs.music_settings

cs.sound_processing	= do ->
	frequencies_to_control			= [32, 64, 125, 250, 500, 1000, 2000, 4000, 8000, 16000] #kHz
	frequencies_types				= ['lowshelf', 'lowshelf', 'lowshelf', 'peaking', 'peaking', 'peaking', 'peaking', 'highshelf', 'highshelf', 'highshelf']
	gain_levels						= music_settings.equalizer_gain_levels || [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	create_equalizer				= (audio) ->
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
	update_equalizer					= (audio) ->
		frequencies	= audio.frequencies
		for frequency, index in frequencies_to_control
			frequencies[index].gain.value	= gain_levels[index]
		return
	reverb_impulse_responses_files	= []
	reverb_impulse_response_load	= (filename, callback) ->
		context		= new AudioContext
		url						= "/audio/reverb_impulse_responses/#{filename}.ogg"
		# Load buffer asynchronously
		request					= new XMLHttpRequest()
		request.open('GET', url, true)
		request.responseType	= 'blob'
		request.onload			= ->
			file_reader = new FileReader();
			file_reader.onload = ->
				# Asynchronously decode the audio file data in request.response
				context.decodeAudioData(
					@result
					(buffer) ->
						if !buffer
							callback()
							return
						callback(buffer)
						return
				)
			file_reader.readAsArrayBuffer(request.response);
			return
		request.send()
		return

	add_to_element	: (element) ->
		audio								= {}
		element.audio_processing			= audio
		audio.context						= new AudioContext
		audio.context.mozAudioChannelType	= 'content'
		audio.source						= audio.context.createMediaElementSource(element)
		audio.source						= create_equalizer(audio)
		# Compressor for smoother sound peaks
		compressor							= audio.context.createDynamicsCompressor()
		compressor.knee.value				= 40	# [0..40]	Range above threshold in dB where compression will be smoothly applied
		compressor.threshold.value			= -10	# [-100..0]	Threshold in dB about which compression will start
		compressor.ratio.value				= 5		# [1..20]	Specified number of dB over the threshold at input will become 1 dB on output
		# Convolver for surround effect
		reverb								= audio.context.createConvolver()
		audio.source.connect(compressor)
		audio.source						= compressor
		audio.source.connect(reverb)
		audio.source						= reverb
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
