package pine.internal;

class SingleChildManager implements ChildrenManager {
  final element:Element;
  var child:Null<Element> = null;

  public function new(element) {
    this.element = element;
  }

  public function hydrate(cursor:HydrationCursor, parent:Null<Element>, ?slot:Slot) {}

  public function update(component:Component) {}

  public function visit(visitor:ElementVisitor) {}

  public function dispose() {}
}
