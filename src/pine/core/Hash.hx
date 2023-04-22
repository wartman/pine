package pine.core;

using StringTools;

/**
  Stolen entirely from here:
  https://github.com/cristianbote/goober/blob/791dc6735dc8a4fae8d76b1dce26e53ed7f0fc8a/src/core/to-hash.js
**/
function hash(str:String, ?digits:Int) {
  var i = 0;
  var out = 11;
  while (i < str.length) {
    out = (101 * out + str.charCodeAt(i++)) >>> 0;
  }
  return out.hex(digits);
}
