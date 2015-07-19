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
	get					: (filename, success_callback, error_callback = ->) ->
		# To be implemented by specific storage
	get_cover			: (filename, success_callback, error_callback = ->) ->
		basename	= do ->
			splitted	= filename.split('/')
			if splitted.length > 1
				splitted.slice(0, -1).join('/') + '/'
			else
				filename.substr(0, 1)
		@get(basename + 'cover.jpg', success_callback, =>
			@get(basename + 'Cover.jpg', success_callback, =>
				@get(basename + 'cover.png', success_callback, =>
					@get(basename + 'Cover.png', success_callback, error_callback)
				)
			)
		)
