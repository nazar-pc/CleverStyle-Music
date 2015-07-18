###*
 * @package   CleverStyle Music
 * @category  app
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2014-2015, Nazar Mokrynskyi
 * @license   MIT License, see license.txt
###
if !navigator.getDeviceStorage
	return
storages		= navigator.getDeviceStorages('sdcard')
cs.storage.scan	= (callback) ->
	files				= []
	scan_storages		= (storages, index) =>
		if !storages.length
			callback(files)
			return
		++index
		storage				= storages.shift()
		cursor				= storage.enumerate()
		cursor.onsuccess	= =>
			if cursor.result
				file = cursor.result
				if @known_extensions.indexOf(file.name.split('.').pop()) != -1
					files.push('' + index + file.name)
				cursor.continue()
			else
				scan_storages(storages, index)
		cursor.onerror = ->
			scan_storages(storages, index)
	scan_storages(
		storages.slice(),
		-1
	)
cs.storage.get	= (filename, success_callback, error_callback = ->) ->
	index				= filename.substr(0, 1)
	filename			= filename.substr(1)
	result				= storages[index].get(filename)
	result.onsuccess	= ->
		if @result
			success_callback(@result)
	result.onerror		= error_callback
