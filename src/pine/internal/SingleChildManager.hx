package pine.internal;

class SingleChildManager implements ChildrenManager {
  final render:()->Null<Component>;
  final factory:ElementFactory;
  var child:Null<Element> = null;

  public function new(render, factory) {
    this.render = render;
    this.factory = factory;
  }

  public function hydrate(cursor:HydrationCursor, ?slot:Slot) {
    var component = render();
    if (component == null) return;
    child = factory.hydrateChild(cursor, component, slot);
  }

  public function update(?previousComponent:Component, ?slot:Slot) {
    child = factory.updateChild(child, render(), slot);
  }

  public function visit(visitor:ElementVisitor) {
    if (child != null) {
      visitor.visit(child);
    }
  }

  public function updateSlot(?slot:Slot) {
    if (child != null) {
      child.updateSlot(slot);
    }
  }

  public function dispose() {
    if (child != null) {
      child.dispose();
      child = null;
    }
  }
}
