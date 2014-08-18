###*
 * @package     CleverStyle Music
 * @category    Web Components
 * @author      Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright   Copyright (c) 2014, Nazar Mokrynskyi
 * @license     MIT License, see license.txt
###

document.webL10n.ready ->
	$body					= $('body')
	music_library			= cs.music_library
	stop					= false
	music_library_action	= document.querySelector('cs-music-library-action')

	Polymer(
		'cs-music-library-grouped'
		list			: []
		grouped_field	: ''
		open			: (group_field, all) ->
			$body.addClass('library-grouped')
			@grouped_field	= group_field
			stop			= false
			index			= 0
			list			= {}
			count			= all.length
			_unknown		= _('unknown')
			get_next_item	= =>
				if index < count
					music_library.get_meta(all[index], (data) =>
						property	= data[group_field]
						if !property
							property	= _unknown
						if !list[property]
							list[property]	= [data.id]
						else
							list[property].push(data.id)
						data	= null
						++index
						get_next_item()
					)
				else if !stop
					final_list	= []
					unknown		= list[_unknown]
					delete list[_unknown]
					for value, items of list
						final_list.push(
							field	: group_field
							value	: value
							items	: JSON.stringify(items)
							count	: items.length
						)
					if unknown
						final_list.push(
							field	: group_field
							value	: _unknown
							items	: JSON.stringify(unknown)
							count	: unknown.length
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
			target	= e.target
			if target.tagName == 'SPAN'
				target	= target.parentNode
			music_library_action.open(
				JSON.parse(target.dataset.items)
			)
		back			: ->
			$body.removeClass('library-grouped')
			@list	= []
			stop	= true
	)
