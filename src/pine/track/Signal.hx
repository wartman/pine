package pine.track;

import haxe.ds.List;

using Lambda;

@:allow(pine.track)
class Signal<T> implements Disposable {
  final comparator:(a:T, b:T) -> Bool;
  final observers:List<Observer> = new List();
  var value:T;
  var isDisposed:Bool = false;

  public function new(initialValue, ?comparator) {
    this.comparator = comparator != null ? comparator : (a, b) -> a != b;
    value = initialValue;
    notify();
  }

  public function get():T {
    if (isDisposed) {
      throw 'Cannot use a signal that has already been disposed.';
    }

    var observer = Observer.stack.last();

    if (observer != null && !observers.has(observer)) {
      observers.add(observer);
      observer.signals.add(this);
    }

    return value;
  }

  public function set(newValue:T):T {
    if (isDisposed) {
      throw 'Cannot use a signal that has already been disposed.';
    }

    if (!comparator(value, newValue)) return value;

    value = newValue;
    notify();

    return value;
  }

  public function dispose() {
    observers.clear();
    isDisposed = true;
  }

  function notify() {
    if (observers.length > 0) {
      Task.batch(task -> for (observer in observers) {
        task.enqueue(observer);
      });
    }
  }
}
