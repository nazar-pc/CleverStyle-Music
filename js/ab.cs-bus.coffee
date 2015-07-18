###*
 * @package   CleverStyle Music
 * @category  app
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2014-2015, Nazar Mokrynskyi
 * @license   MIT License, see license.txt
###
cs.bus	= do ->
	subscribers	= {}
	return {
		state	: {}
		'on'	: (event_name, callback) ->
			if !subscribers[event_name]
				subscribers[event_name]	= []
			subscribers[event_name].push(callback)
			cs.bus
		once	: (event_name, callback) ->
			callback_	= =>
				callback()
				@off(callback_)
			@on(event_name, callback_)
		'off'	: (event_name, callback) ->
			if !subscribers[event_name]
				return cs.bus
			subscribers[event_name].forEach (func, index) ->
				if func == callback
					delete subscribers[event_name][index]
					return false
			cs.bus
		fire	: (event_name, data) ->
			if subscribers[event_name]
				subscribers[event_name].forEach (callback) ->
					requestAnimationFrame ->
						callback(data)
	}
