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
Array::shuffle = ->
	for i in [(@.length - 1) .. 1]
		j = Math.floor(Math.random() * (i + 1))
		[@[i], @[j]] = [@[j], @[i]]
	@
