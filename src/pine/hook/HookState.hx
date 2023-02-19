package pine.hook;

import pine.core.Disposable;

interface HookState<T:Hook> extends Disposable {
  public function update(hook:T):Void;
}
