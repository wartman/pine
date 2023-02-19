package pine.hook;

import pine.state.Observer;

typedef ObserverHookHandler = ()->Null<()->Void>; 

class ObserverHook implements Hook {
  public final handler:ObserverHookHandler;

  public function new(handler) {
    this.handler = handler;
  }

  public function createHookState(context:Context):HookState<Dynamic> {
    return new ObserverHookState(this);
  }
}

class ObserverHookState implements HookState<ObserverHook> {
  final observer:Observer;
  var cleanup:Null<()->Void> = null;
  var hook:ObserverHook;

  public function new(hook) {
    this.hook = hook;
    this.observer = new Observer(() -> {
      if (cleanup != null) cleanup();
      cleanup = this.hook.handler();
    });
  }

  public function update(hook:ObserverHook) {
    this.hook = hook;
  }

  public function dispose() {
    observer.dispose();
    if (cleanup != null) cleanup();
    cleanup = null;
  }
}
