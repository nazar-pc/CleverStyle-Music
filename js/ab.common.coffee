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
Array::shuffle = ->
	for i in [(@.length - 1) .. 1]
		j = Math.floor(Math.random() * (i + 1))
		[@[i], @[j]] = [@[j], @[i]]
	@
window.time_format = (time) ->
	min	= Math.floor(time / 60)
	sec	= Math.floor(time % 60)
	if min < 10
		min = "0#{min}"
	if sec < 10
		sec = "0#{sec}"
	min + ':' + sec
