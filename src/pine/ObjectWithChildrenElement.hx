package pine;

class ObjectWithChildrenElement extends ObjectElement {
  var children:MultipleChildren;

  public function new(component) {
    super(component);
    children = new MultipleChildren(
      () -> cast objectComponent.getChildren(),
      new DefaultElementFactory(this),
      DefaultSlotFactory.instance
    );
  }

  function performUpdateSlot(?slot:Slot) {}

  function performBuild(previousComponent:Null<Component>) {
    if (previousComponent == null) {
      object = applicator.create(component);
      applicator.insert(object, slot, findAncestorObject);
    } else {
      if (previousComponent != component) {
        applicator.update(getObject(), component, previousComponent);
      }
    }
    children.update(previousComponent, slot);
  }

  function performHydrate(cursor:HydrationCursor) {
    object = cursor.current();
    Debug.assert(object != null);
    applicator.update(getObject(), component, null);
    children.hydrate(cursor, slot);
    cursor.next();
  }

  function performDispose() {
    if (object != null) {
      applicator.remove(object, slot);
      object = null;
    }
    children.dispose();
  }

  function visitChildren(visitor:ElementVisitor) {
    children.visit(visitor);
  }
}
