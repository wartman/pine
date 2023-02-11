package pine.hook;

import pine.core.Disposable;

interface HookState<T> extends Disposable {
  public function update(value:T):Void;
}
