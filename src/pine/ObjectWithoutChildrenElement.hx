package pine;

class ObjectWithoutChildrenElement extends ObjectElement {
  public function performBuild(previousComponent:Null<Component>) {
    if (previousComponent == null) {
      object = applicator.create(component);
      applicator.insert(object, slot, findAncestorObject);
    } else {
      if (previousComponent != component) {
        applicator.update(getObject(), component, previousComponent);
      }
    }
  }
  
  function performUpdateSlot(?slot:Slot) {}

  public function performHydrate(cursor:HydrationCursor) {
    object = cursor.current();
    Debug.alwaysAssert(object != null);
    applicator.update(object, component);
    cursor.next();
  }

  public function performDispose() {
    if (object != null) applicator.remove(object, slot);
    object = null;
  }

  public function visitChildren(visitor:ElementVisitor) {}
}
