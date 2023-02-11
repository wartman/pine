package pine.hook;

import pine.state.Signal;

class SignalHook<T> implements HookState<()->T> {
  final signal:Signal<T>;

  public function new(value:()->T) {
    this.signal = new Signal(value());
  }
  
  public function update(value:()->T) {
    signal.set(value());
  }

  public function getSignal() {
    return signal;
  }

  public function dispose() {
    signal.dispose();
  }
}
