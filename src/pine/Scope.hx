package pine;

import pine.debug.Debug;
import pine.signal.*;

class Scope extends View {
  @:fromMarkup
  @:noCompletion
  @:noUsing
  public inline static function fromMarkup(props:{
    @:children public final render:()->Child;
  }) {
    return new Scope(props.render);
  }

  public inline static function wrap(render) {
    return new Scope(render);
  }

  final render:()->Child;
  final owner:Owner = new Owner();

  var child:Null<View> = null;

  public function new(render) {
    this.render = render;
  }

  public function __initialize() {
    owner.own(() -> Observer.track(() -> {
      child?.dispose();
      child = render();
      child.mount(this, getAdaptor(), slot);
    }));
  }

  public function findNearestPrimitive():Dynamic {
    return getParent().findNearestPrimitive();
  }

  public function getPrimitive():Dynamic {
    assert(child != null, 'Attempted to get a primitive from an uninitialized Scope');
    return child.getPrimitive();
  }

  function __updateSlot(previousSlot:Null<Slot>, newSlot:Null<Slot>) {
    child?.setSlot(newSlot);
  }

  function __dispose() {
    owner.dispose();
    child?.dispose();
    child = null;
  }
}
