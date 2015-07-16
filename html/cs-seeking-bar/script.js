// Generated by CoffeeScript 1.9.3

/**
 * @package   CleverStyle Music
 * @category  Web Components
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2014-2015, Nazar Mokrynskyi
 * @license   MIT License, see license.txt
 */

(function() {
  Polymer('cs-seeking-bar', {
    current_time: '00:00',
    duration: '00:00',
    ready: function() {
      this.addEventListener('click', function(e) {
        var percents, progress_container;
        progress_container = this.shadowRoot.querySelector('.progress-container');
        percents = (e.pageX - progress_container.offsetLeft - this.offsetLeft) / progress_container.clientWidth * 100;
        if (percents < 0 || percents > 100 || isNaN(percents)) {
          return;
        }
        return $(this).trigger('seeking-update', {
          percents: percents
        });
      });
      return cs.bus.on('player/pause', (function(_this) {
        return function() {
          return _this.setAttribute('blinking', '');
        };
      })(this)).on('player/play', (function(_this) {
        return function() {
          return _this.removeAttribute('blinking');
        };
      })(this)).on('player/resume', (function(_this) {
        return function() {
          return _this.removeAttribute('blinking');
        };
      })(this));
    }
  });

}).call(this);