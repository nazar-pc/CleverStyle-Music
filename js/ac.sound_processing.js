// Generated by CoffeeScript 1.9.3

/**
 * @package   CleverStyle Music
 * @category  app
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2014-2015, Nazar Mokrynskyi
 * @license   MIT License, see license.txt
 */

(function() {
  var music_settings;

  window.AudioContext = AudioContext || webkitAudioContext;

  music_settings = cs.music_settings;

  cs.sound_processing = (function() {
    var create_compressor, create_equalizer, create_reverb, frequencies_to_control, frequencies_types, gain_levels, reverb_impulse_response_current, reverb_impulse_response_load, reverb_impulse_response_new, reverb_impulse_responses_files, update_equalizer, update_reverb;
    frequencies_to_control = [32, 64, 125, 250, 500, 1000, 2000, 4000, 8000, 16000];
    frequencies_types = ['lowshelf', 'lowshelf', 'lowshelf', 'peaking', 'peaking', 'peaking', 'peaking', 'highshelf', 'highshelf', 'highshelf'];
    gain_levels = music_settings.equalizer_gain_levels || [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    create_equalizer = function(audio) {
      var frequencies, frequency, i, index, len;
      frequencies = [];
      audio.frequencies = frequencies;
      for (index = i = 0, len = frequencies_to_control.length; i < len; index = ++i) {
        frequency = frequencies_to_control[index];
        frequencies[index] = audio.context.createBiquadFilter();
        frequencies[index].frequency.value = frequency;
        frequencies[index].type = frequencies_types[index];
        frequencies[index].gain.value = gain_levels[index];
        frequencies[index].Q.value = 1;
        audio.source.connect(frequencies[index]);
        audio.source = frequencies[index];
      }
    };
    update_equalizer = function(audio) {
      var frequencies, frequency, i, index, len;
      frequencies = audio.frequencies;
      for (index = i = 0, len = frequencies_to_control.length; i < len; index = ++i) {
        frequency = frequencies_to_control[index];
        frequencies[index].gain.value = gain_levels[index];
      }
    };
    reverb_impulse_responses_files = ['Block Inside', 'Cement Blocks', 'Chamber', 'Chateau de Logne, Outside', 'Derlon Sanctuary', 'Five Columns', 'Five Columns Long', 'Greek 7 Echo Hall', 'Hall', 'Highly Damped Large Room', 'In The Silo Revised', 'Inverse Room', 'Large Wide Echo Hall', 'Masonic Lodge', 'Musikvereinsaal', 'Narrow Bumpy Space', 'On a Star', 'Parking Garage', 'Plate', 'Rich Plate', 'Rich Split', 'Ruby Room', 'Scala Milan Opera Hall', 'St Nicolaes Church', 'Trig Room', 'Vocal Duo'];
    reverb_impulse_response_current = music_settings.reverb_mode;
    reverb_impulse_response_new = music_settings.reverb_mode;
    reverb_impulse_response_load = function(filename, callback) {
      var context, request, url;
      if (!filename) {
        callback();
        return;
      }
      context = new AudioContext;
      url = "/audio/reverb_impulse_responses/" + filename + ".ogg";
      request = new XMLHttpRequest();
      request.open('GET', url, true);
      request.responseType = 'blob';
      request.onload = function() {
        var file_reader;
        file_reader = new FileReader();
        file_reader.onload = function() {
          return context.decodeAudioData(this.result, function(buffer) {
            if (!buffer) {
              callback();
              return;
            }
            callback(buffer);
          });
        };
        file_reader.readAsArrayBuffer(request.response);
      };
      request.onerror = function() {
        return callback();
      };
      request.send();
    };
    create_compressor = function(audio) {
      var compressor;
      compressor = audio.context.createDynamicsCompressor();
      audio.compressor = compressor;
      compressor.knee.value = 40;
      compressor.threshold.value = -10;
      compressor.ratio.value = 5;
      audio.source.connect(compressor);
      audio.source = compressor;
    };
    create_reverb = function(audio) {
      var reverb;
      reverb = audio.context.createConvolver();
      audio.reverb = reverb;
      setTimeout((function() {
        return reverb_impulse_response_load(reverb_impulse_response_current, function(buffer) {
          return reverb.buffer = buffer;
        });
      }), 0);
      audio.source.connect(reverb);
      audio.source = reverb;
    };
    update_reverb = function(audio) {
      if (reverb_impulse_response_new === reverb_impulse_response_current) {
        return;
      }
      return setTimeout((function() {
        reverb_impulse_response_current = reverb_impulse_response_new;
        return reverb_impulse_response_load(reverb_impulse_response_current, function(buffer) {
          return audio.reverb.buffer = buffer;
        });
      }), 0);
    };
    return {
      add_to_element: function(element) {
        var audio;
        if (music_settings.low_performance) {
          return;
        }
        audio = {};
        element.audio_processing = audio;
        audio.context = new AudioContext;
        audio.context.mozAudioChannelType = 'content';
        audio.source = audio.context.createMediaElementSource(unwrap(element));
        create_reverb(audio);
        create_equalizer(audio);
        create_compressor(audio);
        return audio.source.connect(audio.context.destination);
      },
      update_element: function(element) {
        var audio;
        audio = element.audio_processing;
        update_equalizer(audio);
        return update_reverb(audio);
      },
      get_gain_levels: function() {
        return gain_levels;
      },
      set_gain_levels: function(new_gain_levels) {
        gain_levels = new_gain_levels;
        music_settings.equalizer_gain_levels = new_gain_levels;
        return cs.bus.fire('sound-processing/update');
      },
      get_reverb_mode: function() {
        return reverb_impulse_response_current;
      },
      get_reverb_modes: function() {
        return reverb_impulse_responses_files;
      },
      set_reverb_mode: function(mode) {
        reverb_impulse_response_new = mode;
        music_settings.reverb_mode = mode;
        return cs.bus.fire('sound-processing/update');
      }
    };
  })();

}).call(this);
