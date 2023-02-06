package pine.state;

import pine.debug.Debug;
import pine.state.Engine;

// @todo: consider replacing the standard computation with this! it should
// solve a lot of our problems. 

class LazyComputation<T> extends Signal<T> {
  final observer:Observer;
  var isInvalid:Bool = true;
  var isRevalidating:Bool = false;

  public function new(handler:()->T) {
    super(null);
    this.observer = new Observer(() -> {
      if (isInvalid) return;

      this.value = handler();
      
      if (!isRevalidating) {
        isInvalid = true;
        isRevalidating = false;
        return;
      }

      notify();
    });
  }

  override function get():T {
    if (isInvalid && !isRevalidating) {
      isInvalid = false;
      isRevalidating = true;
      observer.invalidate();
      validateObservers();
    }
    return value;
  }

  override function dispose() {
    super.dispose();
    observer.dispose();
  }

  override function set(value:T):T {
    Debug.error('Computations are read-only');
  }
}