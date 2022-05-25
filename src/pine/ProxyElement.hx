package pine;

class ProxyElement extends Element {
  var child:Null<Element> = null;
  var proxy(get, never):ProxyComponent;

  inline function get_proxy():ProxyComponent {
    return cast component;
  }

  function render() {
    return proxy.render(this);
  }

  function performHydrate(cursor:HydrationCursor) {
    child = hydrateElementForComponent(cursor, render(), slot);
  }

  function performBuild(previousComponent:Null<Component>) {
    child = updateChild(child, render(), slot);
  }

  public function visitChildren(visitor:ElementVisitor) {
    if (child != null) {
      visitor.visit(child);
    }
  }
}
