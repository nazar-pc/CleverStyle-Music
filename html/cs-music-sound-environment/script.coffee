###*
 * @package     CleverStyle Music
 * @category    Web Components
 * @author      Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright   Copyright (c) 2014-2015, Nazar Mokrynskyi
 * @license     MIT License, see license.txt
###

document.webL10n.ready ->
	$body				= $('body')
	sound_processing	= cs.sound_processing
	modes				= {}
	modes[_('reset')]	= ''
	do ->
		loaded_modes	= sound_processing.get_reverb_modes()
		for mode in loaded_modes
			modes[mode]	= mode

	Polymer(
		'cs-music-sound-environment'
		current_mode	: sound_processing.get_reverb_mode()
		modes			:
			for mode of modes
				mode
		open			: ->
			$body.addClass('sound-environment')
		update_mode		: (e) ->
			@current_mode	= $(e.target).data('mode')
			sound_processing.set_reverb_mode(modes[@current_mode])
		back			: ->
			$body.removeClass('sound-environment')
	)
