// Generated by CoffeeScript 1.9.3

/**
 * @package   CleverStyle Music
 * @category  Web Components
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2014-2015, Nazar Mokrynskyi
 * @license   MIT License, see license.txt
 */

(function() {
  $(function() {
    var music_library, music_library_grouped, music_playlist, player;
    music_library = cs.music_library;
    music_playlist = cs.music_playlist;
    player = document.querySelector('cs-music-player');
    music_library_grouped = document.querySelector('cs-music-library-grouped');
    return Polymer({
      'is': 'cs-music-library',
      behaviors: [cs.behaviors.Screen],
      all_text: _('all-songs'),
      artists_text: _('artists'),
      albums_text: _('albums'),
      genres_text: _('genres'),
      years_text: _('years'),
      ratings_text: _('ratings'),
      loading: false,
      group: function(e) {
        var group_field;
        group_field = $(e.originalTarget).data('group-field');
        return music_library.get_all((function(_this) {
          return function(all) {
            var i, j, len, value;
            for (i = j = 0, len = all.length; j < len; i = ++j) {
              value = all[i];
              all[i] = value.id;
            }
            switch (group_field) {
              case 'artist':
              case 'album':
              case 'genre':
              case 'year':
              case 'rated':
                music_library_grouped.update(group_field, all);
                return _this.go_to_screen('library-grouped');
              default:
                _this.loading = true;
                return music_playlist.set(all, function() {
                  return player.next(function() {
                    this.go_to_screen('player');
                    return this.loading = false;
                  });
                });
            }
          };
        })(this));
      },
      back: function() {
        return this.go_back_screen();
      }
    });
  });

}).call(this);
