package pine.core;

abstract Event0(Array<()->Void>) {
  public inline function new() {
    this = [];
  }

  public inline function add(listener) {
    this.push(listener);
    return () -> this.remove(listener);
  }

  public inline function dispatch() {
    for (listener in this) listener();
  }
}

abstract Event1<A>(Array<(value:A)->Void>) {
  public inline function new() {
    this = [];
  }

  public inline function add(listener) {
    this.push(listener);
    return () -> this.remove(listener);
  }

  public inline function dispatch(value:A) {
    for (listener in this) listener(value);
  }
}

abstract Event2<A, B>(Array<(a:A, b:B)->Void>) {
  public inline function new() {
    this = [];
  }

  public inline function add(listener) {
    this.push(listener);
    return () -> this.remove(listener);
  }

  public inline function dispatch(a:A, b:B) {
    for (listener in this) listener(a, b);
  }
}

abstract Event3<A, B, C>(Array<(a:A, b:B, c:C)->Void>) {
  public inline function new() {
    this = [];
  }

  public inline function add(listener) {
    this.push(listener);
    return () -> this.remove(listener);
  }

  public inline function dispatch(a:A, b:B, c:C) {
    for (listener in this) listener(a, b, c);
  }
}
