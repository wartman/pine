package pine;

class ObjectWithChildrenElement extends ObjectElement {
  var children:Array<Element> = [];

  public function getChildren() {
    return children.copy();
  }

  function performBuild(previousComponent:Null<Component>) {
    if (previousComponent == null) {
      object = applicator.create(component);
      applicator.insert(object, slot, findAncestorObject);
      initializeChildren();
    } else {
      if (previousComponent != component) {
        applicator.update(getObject(), component, previousComponent);
      }
      rebuildChildren();
    }
  }

  function performHydrate(cursor:HydrationCursor) {
    object = cursor.current();
    Debug.assert(object != null);
    applicator.update(getObject(), component, null);

    var components = objectComponent.getChildren();
    var objects = cursor.currentChildren();
    var children:Array<Element> = [];
    var previous:Null<Element> = null;

    for (i in 0...components.length) {
      var comp = components[i];
      if (comp == null) continue;
      var element = hydrateElementForComponent(objects, comp, createSlotForChild(i, previous));
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
      var comp = components[i];
      if (comp == null) continue;
      var element = createElementForComponent(comp, createSlotForChild(i, previous));
      children.push(element);
      previous = element;
    }

    this.children = children;
  }

  function rebuildChildren() {
    var components:Array<Component> = cast objectComponent.getChildren().filter(c -> c != null);
    children = diffChildren(children, components);
  }

  override function dispose() {
    if (object != null) applicator.remove(object, slot);
    super.dispose();

    object = null;
    children = [];
  }

  function visitChildren(visitor:ElementVisitor) {
    for (child in children)
      visitor.visit(child);
  }
}
