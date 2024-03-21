package pine.component;

import pine.signal.Signal;
import pine.debug.Debug;

enum abstract DropdownStatus(Bool) {
  final Open = true;
  final Closed = false;
}

@:fallback(error('No DropdownContext found'))
class DropdownContext implements Context {
  public final status:Signal<DropdownStatus> = new Signal(Closed);
  
  public var items(default, null):Array<View> = [];

  public function new() {}
  
  public function open() {
    status.set(Open);
  }

  public function close() {
    status.set(Closed);
  }

  public function toggle() {
    status.update(status -> status == Open ? Closed : Open);
  }

  public function register(view:View) {
    items.push(view);
  }

  public function reset() {
    items = [];
  }

  public function dispose() {
    reset();
  }
}
