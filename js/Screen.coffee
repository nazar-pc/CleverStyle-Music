###*
 * @package   CleverStyle Music
 * @category  Web Components
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2015, Nazar Mokrynskyi
 * @license   MIT License, see license.txt
###

cs.behaviors.Screen	=
	properties		:
		show	:
			type				: Boolean
			value				: false
			reflectToAttribute	: true
	go_to_screen	: (screen, back = false) ->
		document.querySelector('[show]').set('show', false)
		target	= document.querySelector('cs-music-' + screen)
		if !back
			target.screen_from	= @get_screen_name()
		target.set('show', true)
	go_back_screen	: ->
		@go_to_screen(@screen_from, true)
	get_screen_name	: ->
		@tagName.toLowerCase().substr(9)
