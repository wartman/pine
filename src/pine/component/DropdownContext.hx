package pine.component;

import pine.debug.Debug;
import pine.signal.Signal;

enum abstract DropdownStatus(Bool) {
  final Open = true;
  final Closed = false;
}

@:fallback(error('No DropdownContext found'))
class DropdownContext implements Context {
  public final attachment:PositionedAttachment;
  public final gap:Int;
  public final status:Signal<DropdownStatus>;
  public final items:Array<View> = [];

  public function new(attachment, status, ?gap) {
    this.attachment = attachment;
    this.status = status;
    this.gap = gap ?? 0;
  }

  public function open() {
    status.set(Open);
  }

  public function close() {
    status.set(Closed);
  }

  public function toggle() {
    status.update(status -> status == Open ? Closed : Open);
  }

  public function register(view) {
    items.push(view);
  }

  public function dispose() {}
}
