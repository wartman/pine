package pine.bridge;

using StringTools;
using haxe.io.Path;

class RouteParser {
  static inline final SPLIT = ':SPLIT:';

  final source:String;
  var position:Int = 0;
  var start:Int = 0;
  var matcher:String;
  var params:Array<{ key:String, type:String }> = [];

  public function new(source:String) {
    this.source = source.normalize();
    parse();
  }

  public function getMatcher() {
    return '^' + matcher + '$';
  }

  public function getParams() {
    return params;
  }
  
  public function getParts() {
    position = 0;
    start = 0;
    var out = '';
    while (!isAtEnd()) {
      if (match('{')) {
        readWhile(() -> !check('}'));
        consume('}');
        out += SPLIT;
      } else {
        out += advance();
      }
    }
    return out.split(SPLIT);
  }

  function parse() {
    position = 0;
    start = 0;
    var re = [ while (!isAtEnd()) parsePart() ].join('');
    this.matcher = re;
  }

  function parsePart():String {
    start = position;
    return switch advance() {
      case '{': '(' + parseCapture() + ')';
      case c: c;
    }
  }

  function parseCapture():String {
    ignoreWhitespace();
    var mode = match('?') ? '*' : '+';
    var key = readWhile(() -> !check(':') && !check('}'));
    var type = 'String';
    var matcher = '\\w';
    if (match(':')) {
      var t = readWhile(() -> isAlphaNumeric(peek()) && !check('}'));
      switch t {
        case 'String': 
          matcher = '[a-zA-Z0-9\\-_]';
        case 'Int': 
          matcher = '\\d';
          type = 'Int';
        case other: 
          matcher = other; // assume a valid regexp
      }
    }
    ignoreWhitespace();
    consume('}');
    params.push({ key: key, type: type });
    return '$matcher$mode';
  }

  function ignoreWhitespace() {
    readWhile(() -> check(' '));
  }

  function match(value:String) {
    if (check(value)) {
      position = position + value.length;
      return true;
    }
    return false;
  }
  
  function isDigit(c:String):Bool {
    return c >= '0' && c <= '9';
  }

  function isAlpha(c:String):Bool {
    return (c >= 'a' && c <= 'z') ||
           (c >= 'A' && c <= 'Z');
  }

  function isAlphaNumeric(c:String) {
    return isAlpha(c) || isDigit(c);
  }

  function check(value:String) {
    var found = source.substr(position, value.length);
    return found == value;
  }

  function peek() {
    return source.charAt(position);
  }

  function previous() {
    return source.charAt(position - 1);
  }

  function advance() {
    if (!isAtEnd()) position++;
    return previous();
  }

  function isAtEnd() {
    return position >= source.length;
  }

  function readWhile(compare:()->Bool):String {
    var out = [ while (!isAtEnd() && compare()) advance() ];
    return out.join('');
  }

  function consume(value:String) {
    if (!match(value)) throw 'Expected ${value}';
  }
}
