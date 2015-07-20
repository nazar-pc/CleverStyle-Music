###*
 * @package   CleverStyle Music
 * @category  app
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2014-2015, Nazar Mokrynskyi
 * @license   MIT License, see license.txt
###
cs.db	=
	read		: (store_name, value, field) ->
		# To be implemented by specific db
	read_all	: (store_name, callback, filter) ->
		# To be implemented by specific db
	count		: (store_name, callback, filter) ->
		# To be implemented by specific db
	insert		: (store_name, data) ->
		# To be implemented by specific db
	'delete'	: (store_name, id) ->
		# To be implemented by specific db
