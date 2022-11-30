package pine.core;

import pine.debug.Debug;
import haxe.ds.Option;

function or<T>(option:Option<T>, def:T) {
  return switch option {
    case Some(value): value;
    case None: def;
  }
}

function orThrow<T>(option:Option<T>, message:String):T {
  return switch option {
    case Some(value): value;
    case None: Debug.error(message);
  }
}
