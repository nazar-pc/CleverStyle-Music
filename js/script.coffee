###*
 * @package     CleverStyle Music
 * @category    app
 * @author      Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright   Copyright (c) 2014, Nazar Mokrynskyi
 * @license     MIT License, see license.txt
###
$ ->
	music_storage		= navigator.getDeviceStorage('music')
	music_library = cs.music_library
	music_library.onready ->
		do ->
			cursor		= music_storage.enumerate()
			cursor.onsuccess = ->
				if @.result
					file = @.result
					music_library.add(file.name)
					this.continue()
				else
					music_library.clean_playlist()
					music_library.get_next_id_to_play (id) ->
						music_library.get(id, (item) ->
							music_storage.get(item.name).onsuccess = ->
								src = window.URL.createObjectURL(@.result)
								$('body').append("<p>#{item.name}</p><audio src='#{src}' controls></audio>")
						)
			cursor.onerror = ->
				console.error(this.error.name)
