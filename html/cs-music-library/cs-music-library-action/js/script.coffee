###*
 * @package     CleverStyle Music
 * @category    Web Components
 * @author      Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright   Copyright (c) 2014, Nazar Mokrynskyi
 * @license     MIT License, see license.txt
###

document.webL10n.ready ->
	$body			= $('body')
	music_playlist	= cs.music_playlist
	player			= document.querySelector('cs-music-player')

	Polymer(
		'cs-music-library-action'
		create_playlist_text	: _('create-playlist')
		add_to_playlist_text	: _('add-to-playlist')
		items					: []
		open			: (items) ->
			@items	= items
			$body.addClass('library-action')
		create_playlist			: ->
			music_playlist.set(@items, =>
				player.next ->
					$body.removeClass('library-action')
			)
		add_to_playlist			: ->
			music_playlist.append(@items, =>
				$body.removeClass('library-action')
			)
		back			: ->
			$body.removeClass('library-action')
	)
