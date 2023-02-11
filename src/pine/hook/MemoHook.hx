package pine.hook;

import pine.debug.Debug;

class MemoHook<T> implements HookState<()->T> {
  final cleanup:Null<(value:T)->Void>;
  var value:Null<T>;

  public function new(createValue:()->T, ?cleanup) {
    this.cleanup = cleanup;
    this.value = createValue();
  }

  public function getValue():T {
    Debug.assert(value != null);
    return value;
  }

  public function update(value:()->T) {}

  public function dispose() {
    if (cleanup != null && value != null) cleanup(value);
    value = null;
  }
}
