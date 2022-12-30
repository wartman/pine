package pine.core;

abstract Event0(Array<()->Void>) {
  public inline function new() {
    this = [];
  }

  public inline function add(listener) {
    this.push(listener);
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
  }

  public inline function dispatch(a:A, b:B, c:C) {
    for (listener in this) listener(a, b, c);
  }
}

abstract Event4<A, B, C, D>(Array<(a:A, b:B, c:C, d:D)->Void>) {
  public inline function new() {
    this = [];
  }

  public inline function add(listener) {
    this.push(listener);
  }

  public inline function dispatch(a:A, b:B, c:C, d:D) {
    for (listener in this) listener(a, b, c, d);
  }
}
