package pine.hook;

import pine.state.*;

class EffectHook implements HookState<()->Null<()->Void>> {
  final computed:LazyComputation<Null<()->Void>>;
  final element:ElementOf<Component>;
  var handler:()->Null<()->Void>;
  var cleanup:Null<()->Void> = null;

  public function new(element, handler) {
    this.handler = handler;
    this.element = element;
    this.computed = new LazyComputation(() -> this.handler());

    element.events.afterInit.add((_, _) -> resolve());
    element.events.afterUpdate.add(_ -> resolve());
  }

  public function update(handler:()->Null<() -> Void>) {
    this.handler = handler;
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
