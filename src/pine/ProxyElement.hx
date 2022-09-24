package pine;

class ProxyElement extends Element {
  final child:SingleChild;
  var isInitialized:Bool = false;
  var proxyComponent(get, never):ProxyComponent;

  inline function get_proxyComponent():ProxyComponent {
    return getComponent();
  }

  public function new(component:ProxyComponent) {
    super(component);
    child = new SingleChild(
      () -> proxyComponent.render(this),
      new ElementFactory(this)
    );
  }

  function performHydrate(cursor:HydrationCursor) {
    initialize();
    child.hydrate(cursor, slot);
  }

  function performBuild(previousComponent:Null<Component>) {
    if (!isInitialized) initialize();
    child.update(previousComponent, slot);
  }
  
  function performUpdateSlot(?slot:Slot) {
    child.updateSlot(slot); 
  }

  function performDispose() {
    child.dispose();
  }

  function initialize() {
    Debug.assert(!isInitialized);
    isInitialized = true;
    proxyComponent.init(this);
  }

  public function visitChildren(visitor:ElementVisitor) {
    child.visit(visitor);
  }
}
