package pine;

import pine.internal.Tracking;

@:allow(pine)
class State<T> implements Disposable {
  var observers:Array<Observer> = [];
  var value:T;
  var isDisposed:Bool = false;
  final comparator:(a:T, b:T) -> Bool;

  public function new(value, ?comparator) {
    this.value = value;
    this.comparator = comparator != null ? comparator : (a, b) -> a != b;
  }

  public function peek() {
    return value;
  }

  public function get():T {
    if (isDisposed) return peek();

    var observer = currentObserver;
    if (observer != null) addObserver(observer);
    return value;
  }

  public function set(value:T):T {
    if (isDisposed) return value;
    
    if (!comparator(this.value, value)) {
      return this.value;
    }

    this.value = value;
    notify();

    return this.value;
  }

  function addObserver(observer:Observer) {
    if (isDisposed) return;
    
    if (!observers.contains(observer)) {
      observers.push(observer);
      observer.trackDependency(this);
    }
  }

  function removeObserver(observer:Observer) {
    if (isDisposed) return;

    observers.remove(observer);
    observer.untrackDependency(this);
  }

  function notify() {
    if (isDisposed) return;
    for (observer in observers) observer.invalidate();
    validateObservers();
  }

  public function dispose() {
    if (isDisposed) return;
    
    isDisposed = true;

    var toRemove = observers.copy();
    observers = [];
    for (observer in toRemove) observer.untrackDependency(this);
  }
}
