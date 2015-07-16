###*
 * @package   CleverStyle Music
 * @category  app
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2014-2015, Nazar Mokrynskyi
 * @license   MIT License, see license.txt
###
if !window.cs
	window.cs = {}
###*
 * Randomize array element order in-place.
 * Using Fisher-Yates shuffle algorithm.
###
Array::shuffle = ->
	length = @length
	if length == 0
		return @
	while --length
		j	= Math.floor(Math.random() * (length + 1))
		temp		= @[length]
		@[length]	= @[j]
		@[j]		= temp
	@
###*
 * Remove duplicates
###
Array::unique	= ->
	@filter (item, index, array) =>
		array.indexOf(item) == index
window.time_format = (time) ->
	min	= Math.floor(time / 60)
	sec	= Math.floor(time % 60)
	if min < 10
		min = "0#{min}"
	if sec < 10
		sec = "0#{sec}"
	min + ':' + sec
