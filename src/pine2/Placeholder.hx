package pine2;

class Placeholder extends ObjectComponent {
  public function new() {}

  function initializeObject() {
    object = getAdaptor()?.createPlaceholderObject();
  }

  public function visitChildren(visitor:(child:Component) -> Bool) {}
}
