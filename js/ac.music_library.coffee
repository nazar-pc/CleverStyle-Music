###*
 * @package   CleverStyle Music
 * @category  app
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2014-2015, Nazar Mokrynskyi
 * @license   MIT License, see license.txt
###
storage				= cs.storage
db					= cs.db
library_size		= -1
store_metadata		= (id, callback, metadata) ->
	db.insert(
		'meta'
		id		: id
		title	: metadata.title || ''
		artist	: metadata.artist || ''
		album	: metadata.album || ''
		genre	: metadata.genre || ''
		year	: metadata.year || metadata.recordingTime || ''
		rated	: metadata.rated || 0
	)(
		callback
		callback
	)
cs.music_library	=
	add				: (name, callback = ->) ->
		callback	= callback.bind(@)
		db.insert(
			'music'
			name	: name
		)(
			callback
			callback
		)
	parse_metadata	: (name, callback = ->) ->
		callback	= callback.bind(@)
		db.read('music', name, 'name') (data) ->
			if data
				store	= (metadata) -> store_metadata(data.id, callback, metadata)
				storage.get(
					data.name
					(blob) ->
						parseAudioMetadata(
							blob
							(metadata) ->
								store(metadata)
							->
								# If unable to get metadata with previous parser - try another one
								url		= URL.createObjectURL(blob)
								asset	= AV.Asset.fromURL(url)
								asset.get('metadata', (metadata) ->
									URL.revokeObjectURL(url)
									if !metadata
										callback()
										return
									store(metadata)
								)
								asset.on('error', ->
									# Get filename
									metadata	= data.name.split('/').pop()
									# remove extension
									metadata	= metadata.split('.')
									metadata.pop()
									metadata	= metadata.join('.')
									# Try to split filename on artist and title
									metadata	= metadata.split('–', 2)
									if metadata.length == 2
										store(
											artist	: $.trim(metadata[0])
											title	: $.trim(metadata[1])
										)
										return
									# Second trial
									metadata	= metadata[0].split(' - ', 2)
									if metadata.length == 2
										store(
											artist	: $.trim(metadata[0])
											title	: $.trim(metadata[1])
										)
										return
									# Assume that filename is title
									store(
										title	: $.trim(metadata[0])
									)
								)
						)
				)
	get				: (id, callback) ->
		callback	= callback.bind(@)
		db.read('music', id) (result) ->
			if result
				callback(result)
	get_meta		: (id, callback) ->
		callback	= callback.bind(@)
		db.read('meta', id) (result) ->
			if result
				callback(result)
			else
				callback(
					id	: id
				)
	get_all			: (callback, filter) ->
		callback	= callback.bind(@)
		db.read_all('music', callback, filter)
	del				: (id, callback = ->) ->
		callback	= callback.bind(@)
		db.delete('music', id) ->
			db.delete('meta', id) callback
	size			: (callback, filter) ->
		callback	= callback.bind(@)
		if library_size >= 0 && !filter
			callback(library_size)
			return
		db.count(
			'music'
			(count) ->
				if !filter
					library_size = count
				callback(count)
			filter
		)
	rescan			: (callback = ->) ->
		callback	= callback.bind(@)
		found_files		= 0
		new_files		= []
		add_new_files	= (files) =>
			if !files.length
				callback()
				return
			filename	= files.shift()
			db.read('music', filename, 'name') (result) =>
				if !result
					@add(filename, ->
						@parse_metadata(filename, ->
							new_files.push(filename)
							++found_files
							cs.bus.fire('library/rescan/found', found_files)
							add_new_files(files)
						)
					)
				else
					new_files.push(filename)
					++found_files
					cs.bus.fire('library/rescan/found', found_files)
					add_new_files(files)
		storage.scan(
			(files) =>
				if !files.length
					alert __('no_files_found')
					return
				###
				 * At first we'll remove old non-existing files, and afterwards will add new found
				###
				@get_all (all) =>
					ids_to_remove	= []
					all.forEach (file) =>
						if file.name not in files
							ids_to_remove.push(file.id)
						return
					remove	= (ids_to_remove) =>
						if !ids_to_remove.length
							add_new_files(files)
							return
						@del(ids_to_remove.pop(), ->
							remove(ids_to_remove)
						)
					remove(ids_to_remove)
		)
		return
