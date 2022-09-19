package pine;

import pine.internal.*;

class ObjectWithChildrenElement extends ObjectElement {
  var children:MultiChildrenManager;

  public function new(component) {
    super(component);
    children = new MultiChildrenManager(
      () -> cast objectComponent.getChildren().filter(c -> c != null),
      new ElementFactory(this)
    );
  }

  function performUpdateSlot(?slot:Slot) {
    children.updateSlot(slot);
  }

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
