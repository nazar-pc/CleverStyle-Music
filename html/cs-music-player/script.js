// Generated by CoffeeScript 1.9.3

/**
 * @package   CleverStyle Music
 * @category  Web Components
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2014-2015, Nazar Mokrynskyi
 * @license   MIT License, see license.txt
 */

(function() {
  var body, music_library, music_playlist, music_settings, music_storage, resize_image, seeking_bar, sound_processing, update_cover_timeout;

  music_storage = navigator.getDeviceStorage('music');

  sound_processing = cs.sound_processing;

  music_library = cs.music_library;

  music_playlist = cs.music_playlist;

  music_settings = cs.music_settings;

  body = document.querySelector('body');

  seeking_bar = null;

  update_cover_timeout = 0;

  resize_image = function(src, max_size, callback) {
    var image;
    image = new Image;
    image.onload = function() {
      var canvas, ctx;
      canvas = document.createElement('canvas');
      if (image.height > max_size || image.width > max_size) {
        image.width *= max_size / image.height;
        image.height = max_size;
      }
      ctx = canvas.getContext('2d');
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      canvas.width = image.width;
      canvas.height = image.height;
      ctx.mozImageSmoothingEnabled = false;
      ctx.drawImage(image, 0, 0, image.width, image.height);
      return callback(canvas.toDataURL());
    };
    return image.src = src;
  };

  Polymer('cs-music-player', {
    title: '',
    artist: '',
    ready: function() {
      seeking_bar = this.shadowRoot.querySelector('cs-seeking-bar');
      $(seeking_bar).on('seeking-update', (function(_this) {
        return function(e, data) {
          return _this.seeking(data.percents);
        };
      })(this));
      this.player = (function(_this) {
        return function() {
          var aurora_player, object_url, play_with_aurora, player_element, playing_started;
          player_element = document.createElement('audio');
          sound_processing.add_to_element(player_element);
          cs.bus.on('sound-processing/update', function() {
            return sound_processing.update_element(player_element);
          });
          aurora_player = null;
          playing_started = 0;
          player_element.mozAudioChannelType = 'content';
          object_url = null;
          player_element.addEventListener('loadeddata', function() {
            URL.revokeObjectURL(object_url);
            return object_url = null;
          });
          player_element.addEventListener('error', function() {
            if (new Date - playing_started > 1000) {
              return _this.player.pause();
            } else {
              return play_with_aurora();
            }
          });
          player_element.addEventListener('ended', function() {
            _this.play();
            switch (music_settings.repeat) {
              case 'one':
                return music_playlist.current(function(id) {
                  return _this.play(id);
                });
              default:
                return _this.next();
            }
          });
          player_element.addEventListener('timeupdate', function() {
            return _this.update(player_element.currentTime, player_element.duration);
          });
          play_with_aurora = function(just_load) {
            aurora_player = AV.Player.fromURL(object_url);
            aurora_player.on('ready', function() {
              return this.device.device.node.context.mozAudioChannelType = 'content';
            });
            aurora_player.on('end', function() {
              _this.play();
              switch (music_settings.repeat) {
                case 'one':
                  return music_playlist.current(function(id) {
                    return _this.play(id);
                  });
                default:
                  return _this.next();
              }
            });
            aurora_player.on('duration', function(duration) {
              duration /= 1000;
              return aurora_player.on('progress', function() {
                return this.update(aurora_player.currentTime / 1000, duration);
              });
            });
            if (!just_load) {
              return aurora_player.play();
            }
          };
          return {
            open_new_file: function(blob, filename, just_load) {
              playing_started = new Date;
              if (this.playing) {
                this.pause();
              }
              if (aurora_player) {
                aurora_player.stop();
                aurora_player = null;
              }
              if (object_url) {
                URL.revokeObjectURL(object_url);
              }
              object_url = URL.createObjectURL(blob);
              if (filename.substr(0, -4) === 'alac' || filename.substr(0, -4) === 'alac.mp3') {
                return play_with_aurora(just_load);
              } else {
                player_element.src = object_url;
                player_element.load();
                this.file_loaded = true;
                if (!just_load) {
                  player_element.play();
                  return this.playing = true;
                }
              }
            },
            play: function() {
              playing_started = new Date;
              if (aurora_player) {
                aurora_player.play();
              } else {
                player_element.play();
              }
              return this.playing = true;
            },
            pause: function() {
              if (aurora_player) {
                aurora_player.pause();
              } else {
                player_element.pause();
              }
              return this.playing = false;
            },
            seeking: function(percents) {
              if (aurora_player) {
                return aurora_player.seek(aurora_player.duration * percents / 100);
              } else if (player_element.duration) {
                player_element.pause();
                player_element.currentTime = player_element.duration * percents / 100;
                if (cs.bus.state.player === 'playing') {
                  return player_element.play();
                } else {
                  return _this.play();
                }
              }
            }
          };
        };
      })(this)();
      return this.play(null, null, true);
    },
    update: function(current_time, duration) {
      var progress_percentage;
      progress_percentage = duration ? current_time / duration * 100 : 0;
      if (progress_percentage !== seeking_bar.progress_percentage && progress_percentage >= 0 && progress_percentage <= 100 && !isNaN(progress_percentage)) {
        seeking_bar.progress_percentage = progress_percentage;
      }
      current_time = time_format(current_time);
      if (current_time !== seeking_bar.current_time) {
        seeking_bar.current_time = current_time;
      }
      duration = duration ? time_format(duration) : '00:00';
      if (duration !== seeking_bar.duration) {
        return seeking_bar.duration = duration;
      }
    },
    play: function(id, callback, just_load) {
      var element, play_button;
      id = !isNaN(parseInt(id)) ? id : void 0;
      if (typeof callback !== 'function') {
        callback = function() {};
      } else {
        callback.bind(this);
      }
      element = this;
      play_button = element.shadowRoot.querySelector('[icon=play]');
      if (this.player.file_loaded && !id) {
        if (this.player.playing) {
          this.player.pause();
          play_button.icon = 'play';
          cs.bus.fire('player/pause');
          return cs.bus.state.player = 'paused';
        } else {
          this.player.play();
          play_button.icon = 'pause';
          cs.bus.fire('player/resume');
          return cs.bus.state.player = 'playing';
        }
      } else if (id) {
        return music_library.get(id, function(data) {
          var get_file;
          get_file = music_storage.get(data.name);
          get_file.onsuccess = function() {
            var blob;
            blob = this.result;
            element.player.open_new_file(blob, data.name, just_load);
            return (function() {
              var update_cover;
              if (!just_load) {
                play_button.icon = 'pause';
                cs.bus.fire('player/play', id);
                cs.bus.state.player = 'playing';
              }
              music_library.get_meta(id, function(data) {
                if (data) {
                  element.title = data.title || _('unknown');
                  element.artist = data.artist;
                  if (data.artist && data.album) {
                    return element.artist += ": " + data.album;
                  }
                } else {
                  element.title = _('unknown');
                  return element.artist = '';
                }
              });
              update_cover = function(cover) {
                var cs_cover;
                cover = cover || 'img/bg.jpg';
                if (body.style.backgroundImage !== ("url(" + cover + ")")) {
                  cs_cover = element.shadowRoot.querySelector('cs-cover');
                  cs_cover.style.backgroundImage = "url(" + cover + ")";
                  if (music_settings.low_performance) {
                    return body.style.backgroundImage = "url(" + cover + ")";
                  } else {
                    return resize_image(cover, Math.max(cs_cover.clientHeight, cs_cover.clientWidth), function(cover) {
                      var el;
                      el = document.createElement('div');
                      return new Blur({
                        el: el,
                        path: cover,
                        radius: 10,
                        callback: function() {
                          body.style.backgroundImage = el.style.backgroundImage;
                          setTimeout((function() {
                            return URL.revokeObjectURL(cover);
                          }), 500);
                          return callback();
                        }
                      });
                    });
                  }
                }
              };
              return parseAudioMetadata(blob, function(metadata) {
                var cover;
                cover = metadata.picture;
                if (cover) {
                  cover = URL.createObjectURL(cover);
                }
                return update_cover(cover);
              }, function() {
                return update_cover('img/bg.jpg');
              });
            })();
          };
          return get_file.onerror = function(e) {
            return alert(_('cant-play-this-file', {
              error: e.target.error.name
            }));
          };
        });
      } else {
        return music_playlist.current((function(_this) {
          return function(id) {
            return _this.play(id, callback, just_load);
          };
        })(this));
      }
    },
    prev: function(callback) {
      return music_playlist.prev((function(_this) {
        return function(id) {
          return _this.play(id, callback);
        };
      })(this));
    },
    next: function(callback) {
      return music_playlist.next((function(_this) {
        return function(id) {
          return _this.play(id, callback);
        };
      })(this));
    },
    menu: function() {
      return this.go_to_screen('menu');
    },
    seeking: function(percents) {
      return this.player.seeking(percents);
    }
  });

}).call(this);
