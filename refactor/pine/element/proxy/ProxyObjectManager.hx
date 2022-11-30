package pine.element.proxy;

import pine.hydration.Cursor;
import pine.debug.Debug;

class ProxyObjectManager implements ObjectManager {
  final element:Element;

  public function new(element) {
    this.element = element;
  }

  public function get():Dynamic {
    var object:Null<Dynamic> = null;

    element.visitChildren(element -> {
      Debug.assert(object == null, 'Element has more than one objects');
      object = element.getObject();
      
      true;
    });

    Debug.alwaysAssert(object != null, 'Element does not have an object');

    return object;
  }

	public function init() {}

  public function update() {}

  public function dispose() {}

	public function hydrate(cursor:Cursor) {}
}
