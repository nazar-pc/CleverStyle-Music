// Generated by LiveScript 1.4.0
/**
 * @package   CleverStyle Music
 * @category  Web Components
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2015, Nazar Mokrynskyi
 * @license   MIT License, see license.txt
 */
(function(){
  var x$, ref$;
  x$ = (ref$ = Polymer.cs || (Polymer.cs = {})).behaviors || (ref$.behaviors = {});
  x$.Language = {
    properties: {
      L: {
        type: Object,
        value: cs.Language
      },
      Language: {
        type: Object,
        value: cs.Language
      }
    },
    __: __
  };
  x$.Screen = {
    properties: {
      show: {
        type: Boolean,
        value: false,
        reflectToAttribute: true,
        observer: 'showChanged'
      }
    },
    showChanged: function(){},
    go_to_screen: function(screen, back){
      var target;
      back == null && (back = false);
      document.querySelector('[show]').show = false;
      target = document.querySelector('cs-music-' + screen);
      if (!back) {
        target.screen_from = this.get_screen_name();
      }
      return target.show = true;
    },
    go_back_screen: function(){
      return this.go_to_screen(this.screen_from, true);
    },
    get_screen_name: function(){
      return this.tagName.toLowerCase().substr(9);
    }
  };
}).call(this);
