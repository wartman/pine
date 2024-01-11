package pine;

import pine.debug.Debug;
import pine.signal.*;

class Scope extends View {
  public inline static function wrap(render) {
    return new Scope(render);
  }

  final render:()->View;

  var link:Disposable;
  var child:Null<View> = null;

  public function new(render) {
    this.render = render;
  }

  public function __initialize() {
    link = new Observer(() -> {
      child?.dispose();
      child = render();
      child.mount(this, getAdaptor(), slot);
    });
  }

  public function findNearestPrimitive():Dynamic {
    return ensureParent().findNearestPrimitive();
  }

  public function getPrimitive():Dynamic {
    assert(child != null);
    return child.getPrimitive();
  }

  function __updateSlot(previousSlot:Null<Slot>, newSlot:Null<Slot>) {
    child?.setSlot(newSlot);
  }

  function __dispose() {
    link?.dispose();
    link = null;
    child?.dispose();
    child = null;
  }
}
