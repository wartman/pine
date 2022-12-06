package pine.diffing;

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
