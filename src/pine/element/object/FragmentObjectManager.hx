package pine.element.object;

import pine.debug.Debug;
import pine.hydration.Cursor;

/**
  This ObjectManager finds the last object in an Element's children.
  This should be used for any object that's Fragment-like. 
**/
class FragmentObjectManager implements ObjectManager {
  final element:Element;

  public function new(element) {
    this.element = element;
  }

  public function get():Dynamic {
    var object:Null<Dynamic> = null;
    element.visitChildren(child -> {
      object = child.getObject();
      true;
    });
    Debug.assert(object != null);
    return object;
  }

  public function move(oldSlot:Null<Slot>, newSlot:Null<Slot>) {}

  public function init() {}

  public function hydrate(cursor:Cursor) {}

  public function update() {}

  public function dispose() {}
}
