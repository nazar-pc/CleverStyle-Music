###*
 * @package     CleverStyle Music
 * @category    Web Components
 * @author      Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright   Copyright (c) 2014, Nazar Mokrynskyi
 * @license     MIT License, see license.txt
###

document.webL10n.ready ->
	$body			= $('body')
	music_library	= cs.music_library
	stop			= false

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
							items	: items.join(',')
							count	: items.length
						)
					if unknown
						final_list.push(
							field	: group_field
							value	: _unknown
							items	: unknown.join(',')
							count	: unknown.length
						)
					@list			= final_list
			get_next_item()
		back			: ->
			$body.removeClass('library-grouped')
			@list	= []
			stop	= true
	)
