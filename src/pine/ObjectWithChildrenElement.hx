package pine;

class ObjectWithChildrenElement extends ObjectElement {
  var children:Array<Element> = [];

  public function getChildren() {
    return children.copy();
  }

  function performBuild(previousComponent:Null<Component>) {
    Debug.alwaysAssert(root != null);
    if (previousComponent == null) {
      object = createObject();
      root.insertObject(object, slot, findAncestorObject);
      initializeChildren();
    } else {
      if (previousComponent != component)
        updateObject(previousComponent);
      rebuildChildren();
    }
  }

  function performHydrate(cursor:HydrationCursor) {
    object = cursor.current();
    Debug.assert(object != null);
    updateObject(object);

    var components = objectComponent.getChildren();
    var objects = cursor.currentChildren();
    var children:Array<Element> = [];
    var previous:Null<Element> = null;

    for (i in 0...components.length) {
      var element = hydrateElementForComponent(objects, components[i], createSlotForChild(i, previous));
      children.push(element);
      previous = element;
    }

    Debug.assert(objects.current() == null);

    cursor.next();

    this.children = children;
  }

  function initializeChildren() {
    var components = objectComponent.getChildren();
    var previous:Null<Element> = null;
    var children:Array<Element> = [];

    for (i in 0...components.length) {
      var element = createElementForComponent(components[i], createSlotForChild(i, previous));
      children.push(element);
      previous = element;
    }

    this.children = children;
  }

  function rebuildChildren() {
    var components = objectComponent.getChildren();
    children = diffChildren(children, components);
  }

  override function updateSlot(slot:Slot) {
    Debug.alwaysAssert(object != null);

    var previousSlot = this.slot;
    this.slot = slot;

    getRoot().moveObject(object, previousSlot, slot, findAncestorObject);
  }

  override function dispose() {
    if (object != null)
      getRoot().removeObject(object, slot);

    super.dispose();

    object = null;
    children = [];
  }

  function visitChildren(visitor:ElementVisitor) {
    for (child in children)
      visitor.visit(child);
  }
}
