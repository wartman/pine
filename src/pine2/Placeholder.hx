package pine2;

class Placeholder extends ObjectComponent {
  public function new() {}

  function initializeObject() {
    object = getAdaptor()?.createPlaceholderObject();
    adaptor?.insertObject(object, slot, findNearestObjectHostAncestor);
  }

  public function visitChildren(visitor:(child:Component) -> Bool) {}
}
