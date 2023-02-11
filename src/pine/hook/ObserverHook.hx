package pine.hook;

import pine.state.Observer;

class ObserverHook implements HookState<()->Null<()->Void>> {
  final observer:Observer;
  var handler:()->Null<()->Void>;
  var cleanup:Null<()->Void> = null;

  public function new(handler) {
    this.handler = handler;
    this.observer = new Observer(() -> {
      if (cleanup != null) cleanup();
      cleanup = this.handler();
    });
  }

  public function update(handler:()->(()->Void)) {
    this.handler = handler;
  }
  
  public function dispose() {
    observer.dispose();
    if (cleanup != null) cleanup();
    cleanup = null;
  }
}
