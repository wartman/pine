package pine.state;

import pine.state.Engine;

@:allow(pine)
class State<T> implements Disposable {
  var value:T;
  var isDisposed:Bool = false;
  final observers:List<Observer> = new List();
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
    if (observer != null) bind(observer, this);
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

  function notify() {
    if (isDisposed) return;
    for (observer in observers) observer.invalidate();
    validateObservers();
  }

  public function dispose() {
    if (isDisposed) return;
    
    isDisposed = true;

    for (observer in observers) unbind(observer, this);
  }
}