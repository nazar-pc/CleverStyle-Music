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
cs.storage.scan	= (each_callback, finish_callback) ->
		cursor				= music_storage.enumerate()
		cursor.onsuccess	= =>
			if cursor.result
				file = cursor.result
				if @known_extensions.indexOf(file.name.split('.').pop()) != -1
					each_callback(file.name)
				cursor.continue()
			else
				finish_callback()
		cursor.onerror = ->
			console.error(@error.name)
