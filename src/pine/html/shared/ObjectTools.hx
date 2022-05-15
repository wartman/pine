package pine.html.shared;

import haxe.DynamicAccess;

// @todo: Make this work with null safety.
//        Frankly it should be fine right now -- I think the compiler just isn't
//        catching the null checks that are being done already. Or I'm missing
//        something.
@:nullSafety(Off)
class ObjectTools {
  static final EMPTY = {};

  public static function diffObject(oldProps:DynamicAccess<Dynamic>, newProps:DynamicAccess<Dynamic>,
      apply:(key:String, oldValue:Dynamic, newValue:Dynamic) -> Void):Int {
    if (oldProps == newProps) return 0;

    var changed:Int = 0;
    var keys = (if (newProps == null) {
      newProps = EMPTY;
      oldProps;
    } else if (oldProps == null) {
      oldProps = EMPTY;
      newProps;
    } else {
      var ret = newProps.copy();
      for (key in oldProps.keys()) ret[key] = true;
      ret;
    }).keys();

    for (key in keys) switch [oldProps[key], newProps[key]] {
      case [a, b] if (a == b):
      case [a, b]:
        apply(key, a, b);
        changed++;
    }

    return changed;
  }

  public static function merge(props:Dynamic, other:Dynamic):Dynamic {
    if (props == other) return props;
    var obj:DynamicAccess<Dynamic> = {};
    diffObject(props, other, (key, a, b) -> {
      if (b == null) {
        obj.set(key, a);
      } else {
        obj.set(key, b);
      }
    });
    return obj;
  }
}
