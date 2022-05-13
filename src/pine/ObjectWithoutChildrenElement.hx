package pine;

class ObjectWithoutChildrenElement extends ObjectElement {
  public function performBuild(previousComponent:Null<Component>) {
    if (previousComponent == null) {
      object = createObject();
      getRoot().insertObject(object, slot, findAncestorObject);
    } else {
      if (previousComponent != component)
        updateObject(previousComponent);
    }
  }

  function performHydrate(cursor:HydrationCursor) {
    object = cursor.current();
    Debug.assert(object != null);
    updateObject(object);
    cursor.next();
  }

  override function dispose() {
    if (object != null)
      getRoot().removeObject(object, slot);
    super.dispose();
    object = null;
  }

  public function visitChildren(visitor:ElementVisitor) {}
}
