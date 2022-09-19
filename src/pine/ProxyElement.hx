package pine;

import pine.internal.*;

class ProxyElement extends Element {
  final child:SingleChildManager; 
  var proxyComponent(get, never):ProxyComponent;

  inline function get_proxyComponent():ProxyComponent {
    return getComponent();
  }

  public function new(component:ProxyComponent) {
    super(component);
    child = new SingleChildManager(
      () -> proxyComponent.render(this),
      new ElementFactory(this)
    );
  }

  function performHydrate(cursor:HydrationCursor) {
    child.hydrate(cursor, slot);
    proxyComponent.init(this);
  }

  function performBuild(previousComponent:Null<Component>) {
    child.update(previousComponent, slot);
    if (previousComponent == null) proxyComponent.init(this);
  }
  
  function performUpdateSlot(?slot:Slot) {
    child.updateSlot(slot); 
  }

  function performDispose() {
    child.dispose();
  }

  public function visitChildren(visitor:ElementVisitor) {
    child.visit(visitor);
  }
}
