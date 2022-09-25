package pine;

class SingleChild implements Children {
  final render:()->Null<Component>;
  final elements:ElementFactory;
  var child:Null<Element> = null;

  public function new(render, elements) {
    this.render = render;
    this.elements = elements;
  }

  public function hydrate(cursor:HydrationCursor, ?slot:Slot) {
    var component = render();
    if (component == null) return;
    child = elements.hydrate(cursor, component, slot);
  }

  public function update(?previousComponent:Component, ?slot:Slot) {
    child = elements.update(child, render(), slot);
  }

  public function visit(visitor:ElementVisitor) {
    if (child != null) {
      visitor.visit(child);
    }
  }

  public function dispose() {
    if (child != null) {
      child.dispose();
      child = null;
    }
  }
}
