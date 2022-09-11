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

  function performHydrate(cursor:HydrationCursor) {
    object = cursor.current();
    Debug.alwaysAssert(object != null);
    applicator.update(object, component);
    cursor.next();
  }

  override function dispose() {
    if (object != null) applicator.remove(object, slot);
    super.dispose();
    object = null;
  }

  public function visitChildren(visitor:ElementVisitor) {}
}
