###*
 * @package   CleverStyle Music
 * @category  Web Components
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2014-2015, Nazar Mokrynskyi
 * @license   MIT License, see license.txt
###

document.webL10n.ready ->
	music_library			= cs.music_library
	music_playlist			= cs.music_playlist
	player					= document.querySelector('cs-music-player')
	music_library_grouped	= document.querySelector('cs-music-library-grouped')

	Polymer(
		'cs-music-library'
		all_text		: _('all-songs')
		artists_text	: _('artists')
		albums_text		: _('albums')
		genres_text		: _('genres')
		years_text		: _('years')
		ratings_text	: _('ratings')
		loading			: false
		group			: (e) ->
			group_field		= $(e.originalTarget).data('group-field')
			music_library.get_all (all) =>
				for value, i in all
					all[i] = value.id
				switch group_field
					when 'artist', 'album', 'genre', 'year', 'rated'
						music_library_grouped.update(group_field, all)
						@go_to_screen('library-grouped')
					else
						@loading	= true
						music_playlist.set(all, =>
							player.next ->
								@go_to_screen('player')
								@loading	= false
						)
		back			: ->
			@go_back_screen()
	)
