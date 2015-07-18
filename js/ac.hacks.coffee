###*
 * @package   CleverStyle Music
 * @category  app
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2015, Nazar Mokrynskyi
 * @license   MIT License, see license.txt
###
###
 # Fix for jQuery "ready" event, trigger it after "WebComponentsReady" event triggered by WebComponents.js and after "localized" event triggered by document.webL10n
###
do ($ = jQuery) ->
	ready_original		= $.fn.ready
	functions			= []
	webcomponents_ready	= false
	localization_ready	= false
	$.fn.ready = (fn) ->
		functions.push(fn)
	restore_original_ready	= ->
		$.fn.ready	= ready_original
		functions.forEach (fn) ->
			$(fn)
		functions	= []
	document.addEventListener('WebComponentsReady', ->
		if !webcomponents_ready
			webcomponents_ready	= true
			if localization_ready
				restore_original_ready()
	)
	document.addEventListener('localized', ->
		if !localization_ready
			localization_ready	= true
			if webcomponents_ready
				restore_original_ready()
	)
