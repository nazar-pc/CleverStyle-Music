###*
 * @package     CleverStyle Music
 * @category    Web Components
 * @author      Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright   Copyright (c) 2014-2015, Nazar Mokrynskyi
 * @license     MIT License, see license.txt
###

Polymer(
	'cs-seeking-bar'
	current_time	: '00:00'
	duration		: '00:00'
	ready			: ->
		@addEventListener('click', (e) ->
			progress_container	= @.shadowRoot.querySelector('.progress-container')
			percents			= (e.pageX - progress_container.offsetLeft - @offsetLeft) / progress_container.clientWidth * 100
			if percents < 0 || percents > 100 || isNaN(percents)
				return
			$(@).trigger(
				'seeking-update'
				percents	: percents
			)
		)
		cs.bus
			.on(
				'player/pause'
				=>
					@setAttribute('blinking', '')
			)
			.on(
				'player/play'
				=>
					@removeAttribute('blinking')
			)
			.on(
				'player/resume'
				=>
					@removeAttribute('blinking')
			)
)
