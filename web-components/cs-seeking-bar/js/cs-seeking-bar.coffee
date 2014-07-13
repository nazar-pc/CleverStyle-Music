###*
 * @package     CleverStyle Music
 * @category    Web Components
 * @author      Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright   Copyright (c) 2014, Nazar Mokrynskyi
 * @license     MIT License, see license.txt
###

Polymer(
	'cs-seeking-bar'
	ready	: ->
		window.x = @
		@addEventListener('click', (e) ->
			progress_container	= @.shadowRoot.querySelector('.progress-container')
			percents			= (e.pageX - progress_container.offsetLeft - @offsetLeft) / progress_container.clientWidth * 100
			if percents < 0 || percents > 100
				return
			$(@).trigger(
				'seeking-update'
				percents	: percents
			)
		)
)
