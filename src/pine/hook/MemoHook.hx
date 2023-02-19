package pine.hook;

import pine.core.HasAutoConstructor;
import pine.debug.Debug;

class MemoHook<T> implements Hook implements HasAutoConstructor {
  public final create:()->T;
  public final cleanup:Null<(value:T)->Void>;

  public function createHookState(context:Context):HookState<Dynamic> {
    return new MemoHookState(this);
  }
}

class MemoHookState<T> implements HookState<MemoHook<T>> {
  var value:Null<T>;
  var hook:MemoHook<T>;
  
  public function new(hook) {
    this.hook = hook;
    this.value = hook.create();
  }

  public function getValue():T {
    Debug.assert(value != null);
    return value;
  }

  public function update(hook:MemoHook<T>) {
    this.hook = hook;
  }

  public function dispose() {
    if (hook.cleanup != null && value != null) hook.cleanup(value);
    value = null;
  }
}
