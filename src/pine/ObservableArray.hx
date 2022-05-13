package pine;

@:forward
abstract ObservableArray<T>(ObservableArrayImpl<T>) from ObservableArrayImpl<T> to ObservableHost<Array<T>> {
  public var length(get, never):Int;

  inline function get_length() {
    return this.read().length;
  }

  @:from
  public static function ofNestedObservableHostArray<R, T:ObservableHost<R>>(items:Array<T>):ObservableArray<T> {
    return new NestedObservableHostArray(items);
  }

  // @:from
  // public static function ofNestedObservableArray<R, T:Observable<R>>(items:Array<T>):ObservableArray<T> {
  //   return new NestedObservableArray(items);
  // }

  @:from
  public static function ofArray<T>(items:Array<T>):ObservableArray<T> {
    return new SimpleObservableArray(items);
  }

  @:to
  public inline function toArray():Array<T> {
    return this.read().copy();
  }

  public inline function push(value:T) {
    this.addItem(value);
  }

  public inline function remove(value:T) {
    this.removeItem(value);
  }

  public inline function filter(elt) {
    return this.read().filter(elt);
  }

  public inline function mutate(elt) {
    this.update(this.read().filter(elt));
  }

  public inline function where(elt, ?options) {
    return this.map(data -> data.filter(elt), options);
  }

  public inline function wherePersistent(elt, ?shouldUpdate) {
    return where(elt, {autoDispose: false, shouldUpdate: shouldUpdate});
  }

  public inline function iterator() {
    return this.read().iterator();
  }

  public inline function indexOf(item:T) {
    return this.read().indexOf(item);
  }

  @:op([])
  public inline function at(index:Int) {
    return this.read()[index];
  }

  @:op([])
  public inline function insert(index:Int, value:T) {
    return this.read()[index] = value;
  }
}

private abstract class ObservableArrayImpl<T> extends Observable<Array<T>> {
  abstract public function addItem(item:T):Void;

  abstract public function removeItem(item:T):Void;
}

private class SimpleObservableArray<T> extends ObservableArrayImpl<T> {
  public function addItem(item:T) {
    observedValue.push(item);
    notify();
  }

  public function removeItem(item:T) {
    observedValue.remove(item);
    notify();
  }
}

// // @todo: I think we can skip this as Observables implement ObservableHost.
// // Need to actually test that though.
// private class NestedObservableArray<T:Observable<R>, R> extends ObservableArrayImpl<T> {
//   var links:Array<Disposable> = [];
//   public function new(value) {
//     super(value);
//     for (item in value) {
//       links.push(item.bindNext(_ -> notify()));
//     }
//   }
//   public function addItem(item:T) {
//     observedValue.push(item);
//     links.push(item.bindNext(_ -> notify()));
//     notify();
//   }
//   public function removeItem(item:T) {
//     var index = observedValue.indexOf(item);
//     if (index < 0) {
//       return;
//     }
//     var link = links[index];
//     observedValue.remove(item);
//     links.remove(link);
//     link.dispose();
//     notify();
//   }
//   override function dispose() {
//     super.dispose();
//     for (link in links) {
//       link.dispose();
//     }
//     links = [];
//   }
// }

private class NestedObservableHostArray<T:ObservableHost<R>, R> extends ObservableArrayImpl<T> {
  var links:Array<Disposable> = [];

  public function new(value) {
    super(value);
    for (item in value) {
      links.push(item.observe().bindNext(_ -> notify()));
    }
  }

  public function addItem(item:T) {
    observedValue.push(item);
    links.push(item.observe().bindNext(_ -> notify()));
    notify();
  }

  public function removeItem(item:T) {
    var index = observedValue.indexOf(item);
    if (index < 0) {
      return;
    }
    var link = links[index];
    observedValue.remove(item);
    links.remove(link);
    link.dispose();
    notify();
  }

  override function dispose() {
    super.dispose();
    for (link in links) {
      link.dispose();
    }
    links = [];
  }
}
