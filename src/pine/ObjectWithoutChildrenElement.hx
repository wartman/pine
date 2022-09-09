package pine;

class ObjectWithoutChildrenElement extends ObjectElement {
  public function performBuild(previousComponent:Null<Component>) {
    var adapter = Adapter.from(this);

    if (previousComponent == null) {
      object = objectComponent.createObject(adapter);
      objectComponent.insertObject(adapter, object, slot, findAncestorObject);
    } else {
      if (previousComponent != component) {
        objectComponent.updateObject(adapter, getObject(), previousComponent);
      }
    }
  }

  function performHydrate(cursor:HydrationCursor) {
    object = cursor.current();
    Debug.alwaysAssert(object != null);
    objectComponent.updateObject(Adapter.from(this), object);
    cursor.next();
  }

  override function dispose() {
    if (object != null)
      objectComponent.removeObject(Adapter.from(this), object, slot);
    super.dispose();
    object = null;
  }

  public function visitChildren(visitor:ElementVisitor) {}
}
