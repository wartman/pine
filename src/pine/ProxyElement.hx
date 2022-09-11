package pine;

class ProxyElement extends Element {
  var child:Null<Element> = null;
  var proxyComponent(get, never):ProxyComponent;

  inline function get_proxyComponent():ProxyComponent {
    return getComponent();
  }

  public function new(component:ProxyComponent) {
    super(component);
  }

  function render() {
    return proxyComponent.render(this);
  }

  function performHydrate(cursor:HydrationCursor) {
    child = hydrateElementForComponent(cursor, render(), slot);
    proxyComponent.init(this);
  }

  function performBuild(previousComponent:Null<Component>) {
    child = updateChild(child, render(), slot);
    if (previousComponent == null) proxyComponent.init(this);
  }

  public function visitChildren(visitor:ElementVisitor) {
    if (child != null) {
      visitor.visit(child);
    }
  }
}
