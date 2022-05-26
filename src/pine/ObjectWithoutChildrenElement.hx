package pine;

class ObjectWithoutChildrenElement extends ObjectElement {
  public function performBuild(previousComponent:Null<Component>) {
    if (previousComponent == null) {
      object = objectComponent.createObject(getRoot());
      objectComponent.insertObject(getRoot(), object, slot, findAncestorObject);
    } else {
      if (previousComponent != component) {
        objectComponent.updateObject(getRoot(), getObject(), previousComponent);
      }
    }
  }

  function performHydrate(cursor:HydrationCursor) {
    object = cursor.current();
    Debug.alwaysAssert(object != null);
    objectComponent.updateObject(getRoot(), object);
    cursor.next();
  }

  override function dispose() {
    if (object != null)
      objectComponent.removeObject(getRoot(), object, slot);
    super.dispose();
    object = null;
  }

  public function visitChildren(visitor:ElementVisitor) {}
}
