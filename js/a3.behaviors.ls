/**
 * @package   CleverStyle Music
 * @category  Web Components
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2015, Nazar Mokrynskyi
 * @license   MIT License, see license.txt
 */

Polymer.{}cs.{}behaviors
	..Language	=
		properties	:
			L			:
				type	: Object
				value	: cs.Language
			Language	:
				type	: Object
				value	: cs.Language
		__ : __
	..Screen	=
		properties		:
			show	:
				type				: Boolean
				value				: false
				reflectToAttribute	: true
				observer			: 'showChanged'
		showChanged		: ->
		go_to_screen	: (screen, back = false) ->
			document.querySelector('[show]').show	= false
			target	= document.querySelector('cs-music-' + screen)
			if !back
				target.screen_from	= @get_screen_name()
			target.show	= true
		go_back_screen	: ->
			@go_to_screen(@screen_from, true)
		get_screen_name	: ->
			@tagName.toLowerCase().substr(9)
