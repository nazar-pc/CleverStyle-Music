###*
 * @package   CleverStyle Music
 * @category  Web Components
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2015, Nazar Mokrynskyi
 * @license   MIT License, see license.txt
###

Polymer(
	'is'		: 'cs-music-menu-item'
	properties	:
		icon	: String
	icon_class	: (icon) ->
		"fa fa-#{icon}"
)
