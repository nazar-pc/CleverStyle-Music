###*
 * @package     CleverStyle Music
 * @category    app
 * @author      Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright   Copyright (c) 2014, Nazar Mokrynskyi
 * @license     MIT License, see license.txt
###
if !window.cs
	window.cs = {}
###*
 * Randomize array element order in-place.
 * Using Fisher-Yates shuffle algorithm.
###
Array::shuffle = ->
	for i in [(@length - 1) .. 1]
		j = Math.floor(Math.random() * (i + 1))
		[@[i], @[j]] = [@[j], @[i]]
	@
###*
 * Remove duplicates
###
Array::unique = ->
	array	= @concat()
	for first_val, i in array
		for second_val, j in array when j >= i + 1
			if first_val == second_val
				array.splice(j--, 1)
	return array
window.time_format = (time) ->
	min	= Math.floor(time / 60)
	sec	= Math.floor(time % 60)
	if min < 10
		min = "0#{min}"
	if sec < 10
		sec = "0#{sec}"
	min + ':' + sec
