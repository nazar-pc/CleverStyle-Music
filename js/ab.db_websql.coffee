###*
 * @package   CleverStyle Music
 * @category  app
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2015, Nazar Mokrynskyi
 * @license   MIT License, see license.txt
###
if !window.openDatabase || window.indexedDB
	return
db				= null
on_db_ready		= []
openDatabase('music_db', '3.0', 'Music DB', 5 * 1024 * 1024, (new_db) ->
	new_db.changeVersion('', '3.0', (tx) ->
		tx.executeSql(
			'CREATE TABLE `music` (
				`id` INTEGER PRIMARY KEY AUTOINCREMENT,
				`name` TEXT
			)'
		)
		tx.executeSql(
			'CREATE TABLE `meta` (
				`id` INTEGER PRIMARY KEY,
				`album` TEXT,
				`artist` TEXT,
				`genre` TEXT,
				`rated` TEXT,
				`title` TEXT,
				`year` TEXT
			)'
			[]
			(tx) ->
				tx.executeSql('CREATE INDEX `album` ON `meta` (`album`)', [], (tx) ->
					tx.executeSql('CREATE INDEX `artist` ON `meta` (`artist`)', [], (tx) ->
						tx.executeSql('CREATE INDEX `genre` ON `meta` (`genre`)', [], (tx) ->
							tx.executeSql('CREATE INDEX `rated` ON `meta` (`rated`)', [], (tx) ->
								tx.executeSql('CREATE INDEX `title` ON `meta` (`title`)', [], (tx) ->
									tx.executeSql('CREATE INDEX `year` ON `meta` (`year`)', [], (tx) ->
										db	= new_db
										while callback = on_db_ready.shift()
											callback()
									)
								)
							)
						)
					)
				)
		)
	)
)
onready			= (callback) ->
	callback	= callback.bind(@)
	if db
		callback()
	else
		on_db_ready.push(callback)
	return
wrap			= (request_callback) ->
	(success_callback, error_callback) ->
		onready	->
			request_callback(success_callback, error_callback)
cs.db.read		= (store_name, value, field = 'id') ->
	wrap (success_callback, error_callback) ->
		db.readTransaction (tx) ->
			tx.executeSql(
				"SELECT *
				FROM `#{store_name}`
				WHERE `#{field}` = ?"
				[value]
				(tx, results) ->
					if results.rows.length
						success_callback(results.rows.item(0))
					else
						error_callback()
				error_callback
			)
cs.db.read_all	= (store_name, callback, filter) ->
	onready	->
		db.readTransaction (tx) ->
			tx.executeSql(
				"SELECT *
				FROM `#{store_name}`"
				[]
				(tx, results) ->
					all	= []
					for i in [0..results.rows.length - 1]
						current_item	= results.item(i)
						if !filter || filter(current_item)
							all.push(current_item)
					callback(all)
			)
cs.db.count		= (store_name, callback, filter) ->
	onready	->
		db.readTransaction (tx) ->
			tx.executeSql(
				"SELECT *
				FROM `#{store_name}`"
				[]
				(tx, results) ->
					count	= 0
					for i in [0..results.rows.length - 1]
						current_item	= results.item(i)
						if !filter || filter(current_item)
							++count
					callback(count)
			)
cs.db.insert	= (store_name, data) ->
	wrap (success_callback, error_callback) ->
		db.transaction (tx) ->
			columns			= []
			values			= []
			placeholders	= []
			for column, value of data
				columns.push(column)
				values.push(value)
				placeholders.push('?')
			columns			= '`' + columns.join('`, `') + '`'
			placeholders	= placeholders.join(',')
			tx.executeSql(
				"INSERT INTO `#{store_name}` (#{columns}) VALUES (#{placeholders})",
				values
				success_callback
				error_callback
			)
cs.db.delete	= (store_name, id) ->
	wrap (success_callback, error_callback) ->
		db.transaction (tx) ->
			tx.executeSql(
				"DELETE FROM `#{store_name}`
				WHERE `id` = ?",
				[id]
				success_callback
				error_callback
			)
