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
		frequencies			= []
		audio.frequencies	= frequencies
		for frequency, index in frequencies_to_control
			frequencies[index]					= audio.context.createBiquadFilter()
			frequencies[index].frequency.value	= frequency
			frequencies[index].type				= frequencies_types[index]
			frequencies[index].gain.value		= gain_levels[index]
			frequencies[index].Q.value			= 1
			audio.source.connect(frequencies[index])
			audio.source						= frequencies[index]
		return
	update_equalizer					= (audio) ->
		frequencies	= audio.frequencies
		for frequency, index in frequencies_to_control
			frequencies[index].gain.value	= gain_levels[index]
		return
	reverb_impulse_responses_files	= [
		'Block Inside'
		'Cement Blocks'
		'Chamber'
		'Chateau de Logne, Outside'
		'Derlon Sanctuary'
		'Five Columns'
		'Five Columns Long'
		'Greek 7 Echo Hall'
		'Hall'
		'Highly Damped Large Room'
		'In The Silo Revised'
		'Inverse Room'
		'Large Wide Echo Hall'
		'Masonic Lodge'
		'Musikvereinsaal'
		'Narrow Bumpy Space'
		'On a Star'
		'Parking Garage'
		'Plate'
		'Rich Plate'
		'Rich Split'
		'Ruby Room'
		'Scala Milan Opera Hall'
		'St Nicolaes Church'
		'Trig Room'
		'Vocal Duo'
	]
	reverb_impulse_response_current	= music_settings.reverb_mode
	reverb_impulse_response_load	= (filename, callback) ->
		if !filename
			callback()
			return
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
		request.onerror			= ->
			callback()
		request.send()
		return
	# Compressor for smoother sound peaks
	create_compressor				= (audio) ->
		compressor					= audio.context.createDynamicsCompressor()
		audio.compressor			= compressor
		compressor.knee.value		= 40	# [0..40]	Range above threshold in dB where compression will be smoothly applied
		compressor.threshold.value	= -10	# [-100..0]	Threshold in dB about which compression will start
		compressor.ratio.value		= 5		# [1..20]	Specified number of dB over the threshold at input will become 1 dB on output
		audio.source.connect(compressor)
		audio.source				= compressor
		return
	# Reverb for surround effect
	create_reverb					= (audio) ->
		reverb			= audio.context.createConvolver()
		audio.reverb	= reverb
		setTimeout (->
			reverb_impulse_response_load(
				reverb_impulse_response_current
				(buffer) ->
					reverb.buffer	= buffer
			)
		), 0
		audio.source.connect(reverb)
		audio.source	= reverb
		return
	update_reverb					= (audio) ->
		setTimeout (->
			reverb_impulse_response_load(
				reverb_impulse_response_current
				(buffer) ->
					audio.reverb.buffer	= buffer
			)
		), 0

	add_to_element		: (element) ->
		audio								= {}
		element.audio_processing			= audio
		audio.context						= new AudioContext
		audio.context.mozAudioChannelType	= 'content'
		audio.source						= audio.context.createMediaElementSource(element)
		create_reverb(audio)
		create_equalizer(audio)
		create_compressor(audio)
		audio.source.connect(audio.context.destination)
	update_element		: (element) ->
		audio	= element.audio_processing
		update_equalizer(audio)
		update_reverb(audio)
	get_gain_levels		: ->
		gain_levels
	set_gain_levels		: (new_gain_levels) ->
		gain_levels								= new_gain_levels
		music_settings.equalizer_gain_levels	= new_gain_levels
		cs.bus.trigger('sound-processing/update')
	get_reverb_mode		: ->
		reverb_impulse_response_current
	get_reverb_modes	: ->
		reverb_impulse_responses_files
	set_reverb_mode		: (mode) ->
		reverb_impulse_response_current	= mode
		music_settings.reverb_mode		= mode
		cs.bus.trigger('sound-processing/update')
