###*
 * @package   CleverStyle Music
 * @category  Web Components
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2014-2015, Nazar Mokrynskyi
 * @license   MIT License, see license.txt
###

$ ->
	music_library			= cs.music_library
	stop					= false
	music_library_action	= document.querySelector('cs-music-library-action')

	Polymer(
		'is'			: 'cs-music-library-grouped'
		behaviors		: [Polymer.cs.behaviors.Screen]
		properties:
			list			: []
			grouped_field	: ''
		update			: (group_field, all) ->
			@grouped_field	= group_field
			stop			= false
			index			= 0
			list			= {}
			count			= all.length
			_unknown		= __('unknown')
			get_next_item	= =>
				if index < count
					music_library.get_meta(all[index], (data) =>
						property	= data[group_field]
						if !property
							property			= _unknown
							lowercase_property	= _unknown
						else
							lowercase_property	= new String(property).toLowerCase()
						if !list[lowercase_property]
							list[lowercase_property]	=
								property	: property
								ids			: [data.id]
						else
							list[lowercase_property].ids.push(data.id)
						data	= null
						++index
						get_next_item()
					)
				else if !stop
					final_list	= []
					unknown		= list[_unknown]
					delete list[_unknown]
					for key, value of list
						final_list.push(
							field	: group_field
							value	: value.property
							items	: value.ids
							count	: value.ids.length
						)
					if unknown
						final_list.push(
							field	: group_field
							value	: _unknown
							items	: unknown.ids
							count	: unknown.ids.length
						)
					final_list.sort (a, b) ->
						a	= a.value
						b	= b.value
						if a == b then 0
						else if a < b then -1
						else 1
					@list			= final_list
			get_next_item()
		choose_action	: (e) ->
			music_library_action.update(e.model.item.items)
			@go_to_screen('library-action')
		back			: ->
			@go_back_screen()
			@list	= []
			stop	= true
	)
