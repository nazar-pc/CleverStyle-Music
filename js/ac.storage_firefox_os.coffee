###*
 * @package   CleverStyle Music
 * @category  app
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2014-2015, Nazar Mokrynskyi
 * @license   MIT License, see license.txt
###
if !navigator.getDeviceStorage
	return
music_storage	= navigator.getDeviceStorage('music')
cs.storage.scan	= (callback) ->
	files				= []
	cursor				= music_storage.enumerate()
	cursor.onsuccess	= =>
		if cursor.result
			file = cursor.result
			if @known_extensions.indexOf(file.name.split('.').pop()) != -1
				files.push(file.name)
			cursor.continue()
		else
			callback(files)
	cursor.onerror = ->
		console.error(@error.name)
cs.storage.get	= (filename, success_callback, error_callback = ->) ->
	result	= music_storage.get(filename)
	result.onsuccess	= ->
		if @result
			success_callback(@result)
	result.onerror		= error_callback
