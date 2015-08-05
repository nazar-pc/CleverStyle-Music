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
    var music_library, music_playlist, music_settings, player, scroll_interval;
    music_library = cs.music_library;
    music_playlist = cs.music_playlist;
    music_settings = cs.music_settings;
    player = document.querySelector('cs-music-player');
    scroll_interval = 0;
    return Polymer({
      'is': 'cs-music-playlist',
      behaviors: [cs.behaviors.Screen],
      properties: {
        list: {
          type: Array,
          value: []
        }
      },
      created: function() {
        return cs.bus.on('player/play', (function(_this) {
          return function(id) {
            if (_this.list.length) {
              return _this.update_status(id);
            }
          };
        })(this)).on('player/pause', (function(_this) {
          return function() {
            if (_this.list.length) {
              return _this.update_status();
            }
          };
        })(this)).on('player/resume', (function(_this) {
          return function() {
            if (_this.list.length) {
              return _this.update_status();
            }
          };
        })(this));
      },
      ready: function() {
        switch (music_settings.repeat) {
          case 'none':
            this.shadowRoot.querySelector('[icon=repeat]').setAttribute('disabled', '');
            break;
          case 'one':
            this.shadowRoot.querySelector('[icon=repeat]').innerHTML = 1;
        }
        if (!music_settings.shuffle) {
          return this.shadowRoot.querySelector('[icon=random]').setAttribute('disabled', '');
        }
      },
      showChanged: function() {
        if (this.show) {
          return this.update();
        }
      },
      update: function() {
        return music_playlist.current((function(_this) {
          return function(current_id) {
            return music_playlist.get_all(function(all) {
              var count, get_next_item, index, list;
              index = 0;
              list = [];
              count = all.length;
              get_next_item = function() {
                if (index < count) {
                  return music_library.get_meta(all[index], function(data) {
                    data.playing = data.id === current_id;
                    data.icon = cs.bus.state.player === 'playing' ? 'play' : 'pause';
                    data.artist_title = [];
                    if (data.artist) {
                      data.artist_title.push(data.artist);
                    }
                    if (data.title) {
                      data.artist_title.push(data.title);
                    }
                    data.artist_title = data.artist_title.join(' — ') || _('unknown');
                    list.push(data);
                    data = null;
                    ++index;
                    return get_next_item();
                  });
                } else if (_this.show) {
                  _this.list = list;
                  return scroll_interval = setInterval((function() {
                    var item, items_container;
                    items_container = _this.shadowRoot.querySelector('cs-music-playlist-items');
                    if (items_container) {
                      item = items_container.querySelector('cs-music-playlist-item[playing]');
                      clearInterval(scroll_interval);
                      scroll_interval = 0;
                      return items_container.scrollTop = item.offsetTop;
                    }
                  }), 100);
                }
              };
              return get_next_item();
            });
          };
        })(this));
      },
      play: function(e) {
        return music_playlist.current((function(_this) {
          return function(old_id) {
            music_playlist.set_current(e.currentTarget.dataset.index);
            return music_playlist.current(function(id) {
              if (id !== old_id) {
                return player.play(id);
              } else {
                return player.play();
              }
            });
          };
        })(this));
      },
      update_status: function(new_id) {
        return this.list.forEach((function(_this) {
          return function(data, index) {
            if (data.id === new_id || (data.playing && !new_id)) {
              _this.set(['list', index, 'playing'], true);
              return _this.set(['list', index, 'icon'], cs.bus.state.player === 'playing' ? 'play' : 'pause');
            } else if (data.playing) {
              _this.set(['list', index, 'playing'], false);
              return _this.set(['list', index, 'icon'], null);
            }
          };
        })(this));
      },
      back: function() {
        this.go_back_screen();
        return requestAnimationFrame((function(_this) {
          return function() {
            _this.list = [];
            if (scroll_interval) {
              clearInterval(scroll_interval);
              return scroll_interval = 0;
            }
          };
        })(this));
      },
      repeat: function(e) {
        var control;
        control = e.target;
        music_settings.repeat = (function() {
          switch (music_settings.repeat) {
            case 'none':
              return 'all';
            case 'all':
              return 'one';
            case 'one':
              return 'none';
          }
        })();
        if (music_settings.repeat === 'none') {
          control.setAttribute('disabled', '');
        } else {
          control.removeAttribute('disabled');
        }
        return control.innerHTML = music_settings.repeat === 'one' ? 1 : '';
      },
      shuffle: function(e) {
        var control;
        control = e.target;
        music_settings.shuffle = !music_settings.shuffle;
        if (!music_settings.shuffle) {
          control.setAttribute('disabled', '');
        } else {
          control.removeAttribute('disabled');
        }
        this.list = [];
        return music_playlist.current((function(_this) {
          return function(id) {
            return music_playlist.refresh(function() {
              music_playlist.set_current_id(id);
              return _this.update();
            });
          };
        })(this));
      },
      icon_class: function(icon) {
        return "fa fa-" + icon;
      }
    });
  });

}).call(this);
