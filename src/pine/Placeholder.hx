package pine;

import pine.internal.Slot;
import pine.debug.Debug;
import pine.internal.ObjectHost;

class Placeholder extends Component implements ObjectHost {
  var object:Null<Dynamic> = null;

  public function new() {}
  
  function getObject():Dynamic {
    assert(object != null);
    return object;
  }

  public function initialize() {
    initializeObject();
  }

  function initializeObject() {
    object = getAdaptor().createPlaceholderObject();
    getAdaptor().insertObject(object, slot, findNearestObjectHostAncestor);
  }

  function disposeObject() {
    if (object != null) {
      getAdaptor().removeObject(object, slot);
      object = null;
    }
  }

  public function visitChildren(visitor:(child:Component) -> Bool) {}

  override function updateSlot(?newSlot:Slot) {
    if (slot == newSlot) return;
    var prevSlot = slot;
    super.updateSlot(newSlot);
    getAdaptor().moveObject(getObject(), prevSlot, slot, findNearestObjectHostAncestor);
  }

  override function dispose() {
    disposeObject();
    super.dispose();
  }
}
