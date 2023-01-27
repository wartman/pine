package pine.state;

import pine.debug.Debug;
import pine.state.Engine;

// @todo: This class probably needs a rethink.
class Computation<T> extends Signal<T> {
  final observer:Observer;

  public function new(handler:() -> T, ?comparator) {
    super(null, comparator);
    var first = true;
    this.observer = new Observer(() -> {
      var newValue = handler();

      if (first) {
        this.value = newValue;
        first = false;
        return;
      }
      
      if (!this.comparator(this.value, newValue)) {
        return;
      }

      this.value = newValue;
      notify();
    });
  }

  public function revalidate() {
    observer.invalidate();
    validateObservers();
  }

  override function dispose() {
    super.dispose();
    observer.dispose();
  }

  override function set(value:T):T {
    Debug.error('Computations are read-only');
  }
}
