package pine.hook;

import pine.state.Signal;

class SignalHook<T> implements Hook {
  public final value:T;

  public function new(value) {
    this.value = value;
  }

	public function createHookState(context:Context):HookState<Dynamic> {
		return new SignalHookState(this);
	}
}

class SignalHookState<T> implements HookState<SignalHook<T>> {
  final signal:Signal<T>;
  var hook:SignalHook<T>;

  public function new(hook) {
    this.hook = hook;
    this.signal = new Signal(hook.value);
  }
  
  public function update(hook) {
    this.hook = hook;
    signal.set(hook.value);
  }

  public function getSignal() {
    return signal;
  }

  public function dispose() {
    signal.dispose();
  }
}
