package pine;

using Lambda;

typedef KeyObject = {};

abstract Key(KeyObject) from KeyObject to KeyObject {
  public static function createMap() {
    return new KeyMap();
  }

  @:from public static function ofFloat(f:Float):Key {
    return Std.string(f);
  }

  public function isString() {
    return (this is String);
  }
}

class KeyMap<T> {
  var strings:Null<Map<String, T>> = null;
  var objects:Null<Map<KeyObject, T>> = null;

  public function new() {}

  public function set(key:Key, value:T) {
    if (key.isString()) {
      var key:String = cast key;
      if (strings == null) {
        strings = [key => value];
      } else {
        strings.set(key, value);
      }
    } else {
      if (objects == null) {
        objects = [key => value];
      } else {
        objects.set(key, value);
      }
    }
  }

  public function get(key:Key):Null<T> {
    return if (key.isString()) {
      var key:String = cast key;
      if (strings == null)
        null
      else
        strings.get(key);
    } else {
      if (objects == null)
        null
      else
        objects.get(key);
    }
  }

  public function remove(key:Key) {
    if (key.isString() && strings != null) {
      var key:String = cast key;
      strings.remove(key);
    } else if (objects != null) {
      objects.remove(key);
    }
  }

  public function isNotEmpty() {
    if (strings == null && objects == null)
      return false;
    var notEmpty = strings != null && strings.count() > 0;
    if (!notEmpty) {
      notEmpty = objects != null && objects.count() > 0;
    }
    return notEmpty;
  }

  public function each(fn:(key:Key, value:T) -> Void) {
    if (strings != null)
      for (key => value in strings)
        fn(key, value);
    if (objects != null)
      for (key => value in objects)
        fn(key, value);
  }
}
