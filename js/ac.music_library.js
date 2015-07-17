// Generated by CoffeeScript 1.9.3

/**
 * @package   CleverStyle Music
 * @category  app
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2014-2015, Nazar Mokrynskyi
 * @license   MIT License, see license.txt
 */

(function() {
  var db, library_size, storage, store_metadata,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  storage = cs.storage;

  db = cs.db;

  library_size = -1;

  store_metadata = function(id, callback, metadata) {
    return db.insert('meta', {
      id: id,
      title: metadata.title || '',
      artist: metadata.artist || '',
      album: metadata.album || '',
      genre: metadata.genre || '',
      year: metadata.year || metadata.recordingTime || '',
      rated: metadata.rated || 0
    })(callback, callback);
  };

  cs.music_library = {
    add: function(name, callback) {
      if (callback == null) {
        callback = function() {};
      }
      callback = callback.bind(this);
      return db.insert('music', {
        name: name
      })(callback, callback);
    },
    parse_metadata: function(name, callback) {
      if (callback == null) {
        callback = function() {};
      }
      callback = callback.bind(this);
      return db.read('music', 'name', name)(function() {
        var data, store;
        if (this.result) {
          data = this.result;
          store = function(metadata) {
            return store_metadata(data.id, callback, metadata);
          };
          return storage.get(data.name, function(blob) {
            return parseAudioMetadata(blob, function(metadata) {
              return store(metadata);
            }, function() {
              var asset, url;
              url = URL.createObjectURL(blob);
              asset = AV.Asset.fromURL(url);
              asset.get('metadata', function(metadata) {
                URL.revokeObjectURL(url);
                if (!metadata) {
                  callback();
                  return;
                }
                return store(metadata);
              });
              return asset.on('error', function() {
                var metadata;
                metadata = data.name.split('/').pop();
                metadata = metadata.split('.');
                metadata.pop();
                metadata = metadata.join('.');
                metadata = metadata.split('–', 2);
                if (metadata.length === 2) {
                  store({
                    artist: $.trim(metadata[0]),
                    title: $.trim(metadata[1])
                  });
                  return;
                }
                metadata = metadata[0].split(' - ', 2);
                if (metadata.length === 2) {
                  store({
                    artist: $.trim(metadata[0]),
                    title: $.trim(metadata[1])
                  });
                  return;
                }
                return store({
                  title: $.trim(metadata[0])
                });
              });
            });
          });
        }
      });
    },
    get: function(id, callback) {
      callback = callback.bind(this);
      return db.read('music', id)(function(result) {
        if (result) {
          return callback(result);
        }
      });
    },
    get_meta: function(id, callback) {
      callback = callback.bind(this);
      return db.read('meta', id)(function(result) {
        if (result) {
          return callback(result);
        } else {
          return callback({
            id: id
          });
        }
      });
    },
    get_all: function(callback, filter) {
      callback = callback.bind(this);
      return db.read_all('music', callback, filter);
    },
    del: function(id, callback) {
      if (callback == null) {
        callback = function() {};
      }
      callback = callback.bind(this);
      return db["delete"]('music', id)(function() {
        return db["delete"]('meta', id)(callback);
      });
    },
    size: function(callback, filter) {
      callback = callback.bind(this);
      if (library_size >= 0 && !filter) {
        callback(library_size);
        return;
      }
      return db.count('music', function(count) {
        if (!filter) {
          library_size = count;
        }
        return callback(count);
      }, filter);
    },
    rescan: function(callback) {
      var add_new_files, found_files, new_files;
      if (callback == null) {
        callback = function() {};
      }
      callback = callback.bind(this);
      found_files = 0;
      new_files = [];
      add_new_files = (function(_this) {
        return function(files) {
          var filename;
          if (!files.length) {
            callback();
            return;
          }
          filename = files.shift();
          return db.read('music', filename, 'name')(function(result) {
            if (!result) {
              return _this.add(filename, function() {
                return this.parse_metadata(filename, function() {
                  new_files.push(filename);
                  ++found_files;
                  cs.bus.fire('library/rescan/found', found_files);
                  return add_new_files(files);
                });
              });
            } else {
              new_files.push(filename);
              ++found_files;
              cs.bus.fire('library/rescan/found', found_files);
              return add_new_files(files);
            }
          });
        };
      })(this);
      storage.scan((function(_this) {
        return function(files) {
          if (!files.length) {
            alert(_('no_files_found'));
            return;
          }

          /*
          				 * At first we'll remove old non-existing files, and afterwards will add new found
           */
          return _this.get_all(function(all) {
            var ids_to_remove, remove;
            ids_to_remove = [];
            all.forEach(function(file) {
              var ref;
              if (ref = file.name, indexOf.call(files, ref) < 0) {
                ids_to_remove.push(file.id);
              }
            });
            remove = function(ids_to_remove) {
              if (!ids_to_remove.length) {
                add_new_files(files);
                return;
              }
              return _this.del(ids_to_remove.pop(), function() {
                return remove(ids_to_remove);
              });
            };
            return remove(ids_to_remove);
          });
        };
      })(this));
    }
  };

}).call(this);
