package pine;

import haxe.ds.List;

using Lambda;

@:allow(pine)
class State<T> implements Disposable {
  final comparator:(a:T, b:T) -> Bool;
  final observers:List<Observer> = new List();
  var value:T;
  var isDisposed:Bool = false;

  public function new(initialValue, ?comparator) {
    this.comparator = comparator != null ? comparator : (a, b) -> a != b;
    value = initialValue;
    notify();
  }

  public function peek():T {
    Debug.assert(!isDisposed, 'Cannot use a state that has already been disposed.');

    return value;
  }

  public function get():T {
    if (isDisposed) {
      Debug.error('Cannot use a state that has already been disposed.');
    }

    var observer = Observer.stack.last();
    if (observer != null) observer.track(this);

    return value;
  }

  public function set(newValue:T):T {
    if (isDisposed) {
      Debug.error('Cannot use a state that has already been disposed.');
    }

    Debug.assert(
      Observer.stack.length == 0, 
      'Updating a state while inside an Observer is not allowed.'
      + ' This could potentially lead to endless loops.'
      + ' If you really need this behavior, you can use `Process.defer(() -> [set your state here])`'
      + ' as an escape hatch, but be very careful that you\'re not updating'
      + ' states the current Observer is tracking.'
      + ' [triggered for value: ${newValue}]'
    );

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
    if (observers.length > 0) Observer.scheduleTrigger(observers);
  }
}
