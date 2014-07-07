// Generated by CoffeeScript 1.4.0

/**
 * @package     CleverStyle Music
 * @category    app
 * @author      Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright   Copyright (c) 2014, Nazar Mokrynskyi
 * @license     MIT License, see license.txt
*/


/**
 * Randomize array element order in-place.
 * Using Fisher-Yates shuffle algorithm.
*/


(function() {

  Array.prototype.shuffle = function() {
    var i, j, _i, _ref, _ref1;
    for (i = _i = _ref = this.length - 1; _ref <= 1 ? _i <= 1 : _i >= 1; i = _ref <= 1 ? ++_i : --_i) {
      j = Math.floor(Math.random() * (i + 1));
      _ref1 = [this[j], this[i]], this[i] = _ref1[0], this[j] = _ref1[1];
    }
    return this;
  };

}).call(this);