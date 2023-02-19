package pine.hook;

import pine.state.*;

typedef EffectHookHandler = ()->Null<()->Void>; 

class EffectHook implements Hook {
  public final handler:EffectHookHandler;

  public function new(handler) {
    this.handler = handler;
  }

  public function createHookState(context:Context):HookState<Dynamic> {
    return new EffectHookState(context, this);
  }
}

class EffectHookState implements HookState<EffectHook> {
  final computed:LazyComputation<Null<()->Void>>;
  final element:ElementOf<Component>;
  var hook:EffectHook;
  var cleanup:Null<()->Void> = null;

  public function new(element, hook) {
    this.hook = hook;
    this.element = element;
    this.computed = new LazyComputation(() -> this.hook.handler());

    element.events.afterInit.add((_, _) -> resolve());
    element.events.afterUpdate.add(_ -> resolve());
  }

  public function update(hook:EffectHook) {
    this.hook = hook;
  }
  
  public function dispose() {
    computed.dispose();
    if (cleanup != null) cleanup();
  }

  function resolve() {
    var prev = this.cleanup;
    cleanup = computed.get();
    if (prev != null && prev != cleanup) prev();
  }
}
