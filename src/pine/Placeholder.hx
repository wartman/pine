package pine;

import pine.debug.Debug;

class Placeholder extends View {
  public static inline function build() {
    return new Placeholder();
  }

  var primitive:Null<Dynamic> = null;

  public function new() {}

  function __initialize() {
    var adaptor = getAdaptor();
    var parent = getParent();

    primitive = adaptor.createPlaceholderPrimitive(slot, parent.findNearestPrimitive);
    adaptor.insertPrimitive(primitive, slot, parent.findNearestPrimitive);
  }

  public function findNearestPrimitive():Dynamic {
    return getPrimitive();
  }

  public function getPrimitive():Dynamic {
    assert(primitive != null);
    return primitive;
  }

  function __updateSlot(previousSlot:Null<Slot>, newSlot:Null<Slot>) {
    var adaptor = getAdaptor();
    var parent = getParent();

    adaptor.movePrimitive(primitive, previousSlot, newSlot, parent.findNearestPrimitive);
  }

  function __dispose() {
    var adaptor = getAdaptor();
    adaptor.removePrimitive(primitive, slot);
  }
}
