###*
 * @package     CleverStyle Music
 * @category    app
 * @author      Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright   Copyright (c) 2014, Nazar Mokrynskyi
 * @license     MIT License, see license.txt
###
###*
 * Randomize array element order in-place.
 * Using Fisher-Yates shuffle algorithm.
###
if !window.cs
	window.cs = {}
cs.bus	= do ->
	subscribers	= {}
	return {
		state	: {}
		'on'	: (event_name, callback) ->
			if !subscribers[event_name]
				subscribers[event_name]	= []
			subscribers[event_name].push(callback)
			cs.bus
		trigger	: (event_name, data) ->
			if subscribers[event_name]
				subscribers[event_name].forEach (callback) ->
					setTimeout (->
						callback(data)
					), 0
	}
