package pine;

import pine.internal.Debug;

class Placeholder extends ObjectComponent {
  public function new() {}

  function initializeObject() {
    assert(adaptor != null);
    object = adaptor?.createPlaceholderObject();
    adaptor?.insertObject(object, slot, findNearestObjectHostAncestor);
  }

  public function visitChildren(visitor:(child:Component) -> Bool) {}
}
