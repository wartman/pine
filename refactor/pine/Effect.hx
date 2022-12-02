package pine;

import pine.state.Observer;

/**
  A simple Controller that can be used to trigger side
  effects when a tracked property changes.
**/
final class Effect<T:Component> implements Controller<T> {
  final handle:(element:ElementOf<T>)->Void;
  
  var observer:Null<Observer> = null;

  public function new(handle) {
    this.handle = handle;
  }

  public function register(element:ElementOf<T>) {
    element.onReady(_ -> {
      if (observer != null) return;
      observer = new Observer(() -> handle(element));
    });
  }
  
  public function dispose() {
    if (observer != null) {
      observer.dispose();
      observer = null;
    }
  }
}
