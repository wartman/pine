package pine;

@component(ProxyComponent)
class ProxyElement extends Element {
  var child:Null<Element> = null;

  function render() {
    var comp = proxyComponent.render(this);
    // Note: We always need an object leaf at the end of our component
    // tree, so we have to handle cases where the user returns `null`. 
    // We don't use `Adapter.from(this).createPlaceholder()` as there
    // is some extra logic needed to ensure it works with hydration,
    // which the Fragment takes care of.
    if (comp == null) comp = new Fragment({ children: [] });
    return comp;
  }

  function performHydrate(cursor:HydrationCursor) {
    child = hydrateElementForComponent(cursor, render(), slot);
    proxyComponent.init(this);
  }

  function performBuild(previousComponent:Null<Component>) {
    child = updateChild(child, render(), slot);
    if (previousComponent == null) proxyComponent.init(this);
  }

  function performDispose() {}

  public function visitChildren(visitor:ElementVisitor) {
    if (child != null) {
      visitor.visit(child);
    }
  }
}
