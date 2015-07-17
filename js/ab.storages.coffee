###*
 * @package   CleverStyle Music
 * @category  app
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2014-2015, Nazar Mokrynskyi
 * @license   MIT License, see license.txt
###
cs.storage	=
	known_extensions	: [
		'mp3',
		'wave',

		'm4a',
		'm4b',
		'm4p',
		'm4r',
		'3gp',
		'mp4',
		'aac',

		'ogg',
		'oga',
		'opus',
		'flac',

		'alac'
	]
	scan				: (callback) ->
		# To be implemented by specific storage
	get					: (filename, callback) ->
		# To be implemented by specific storage
