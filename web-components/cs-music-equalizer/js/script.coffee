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
	update_level_timeout	= 0

	Polymer(
		'cs-music-equalizer'
		frequencies	: music_equalizer.get_gain_levels()
		created		: ->
			@frequencies	= music_equalizer.get_gain_levels()
		ready		: ->
			frequencies	= @frequencies
			$(@.shadowRoot.querySelectorAll('input[type=range]')).ranger(
				vertical	: true
				label		: false
				min			: -20
				max			: 20
				step		: .001
				callback	: (val) ->
					clearTimeout(update_level_timeout)
					update_level_timeout	= setTimeout (=>
						frequencies[$(@).prev().data('index')]	= Math.round(val * 100000) / 100000
						music_equalizer.set_gain_levels(frequencies)
					), 500
			)
		open			: ->
			$body.addClass('equalizer')
		back			: ->
			$body.removeClass('equalizer')
	)
