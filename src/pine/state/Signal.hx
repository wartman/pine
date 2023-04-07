package pine.state;

import pine.core.Disposable;
import pine.state.Engine;

@:allow(pine)
class Signal<T> implements Disposable {
  var value:T;
  final observers:List<Observer> = new List();
  final comparator:(a:T, b:T) -> Bool;
  
  public function new(value, ?comparator) {
    this.value = value;
    this.comparator = comparator ?? (a, b) -> a != b;
  }

  public function peek() {
    return value;
  }

  public function get():T {
    switch currentObserver {
      case null:
      case observer: bind(observer, this);
    }
    return value;
  }

  public function set(value:T):T {
    if (!comparator(this.value, value)) {
      return this.value;
    }

    this.value = value;
    notify();

    return this.value;
  }

  function notify() {
    for (observer in observers) observer.invalidate();
    validateObservers();
  }

  public function dispose() {
    for (observer in observers) unbind(observer, this);
  }
}
