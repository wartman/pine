package pine.core;

import pine.debug.Debug;
import haxe.ds.Option;

function sure<T>(option:Option<T>):T {
  return orThrow(option, 'Expected a value');
}

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

function map<T, R>(option:Option<T>, transform:(value:T)->Option<R>) {
  return switch option {
    case Some(value): transform(value);
    case None: None;
  }
}

inline function some<T>(option:Option<T>, handle:(value:T)->Void):Option<T> {
  switch option {
    case Some(value): handle(value);
    case None:
  }
  return option;
}

inline function none<T>(option:Option<T>, handle:()->Void):Option<T> {
  switch option {
    case Some(_): 
    case None: handle();
  }
  return option;
}
