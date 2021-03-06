// Generated by CoffeeScript 1.9.3

/**
 * @package   CleverStyle Music
 * @category  app
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2015, Nazar Mokrynskyi
 * @license   MIT License, see license.txt
 */


/*
  * Fix for jQuery "ready" event, trigger it after "WebComponentsReady" event triggered by WebComponents.js
 */

(function() {
  (function($) {
    var functions, ready_original, restore_original_ready, webcomponents_ready;
    ready_original = $.fn.ready;
    functions = [];
    webcomponents_ready = false;
    $.fn.ready = function(fn) {
      return functions.push(fn);
    };
    restore_original_ready = function() {
      $.fn.ready = ready_original;
      functions.forEach(function(fn) {
        return $(fn);
      });
      return functions = [];
    };
    return document.addEventListener('WebComponentsReady', function() {
      if (!webcomponents_ready) {
        webcomponents_ready = true;
        return restore_original_ready();
      }
    });
  })(jQuery);

}).call(this);
