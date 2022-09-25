package pine;

class DefaultElementFactory implements ElementFactory {
  final parent:Element;

  public function new(parent) {
    this.parent = parent;
  }

  public function create(component:Component, ?slot:Slot):Element {
    var element = component.createElement();
    element.mount(parent, slot);
    return element;
  }

  public function hydrate(cursor:HydrationCursor, component:Component, ?slot:Slot):Element {
    var element = component.createElement();
    element.hydrate(cursor, parent, slot);
    return element;
  }

  public function update(?child:Element, ?component:Component, ?slot:Slot):Null<Element> {
    if (component == null) {
      if (child != null) destroy(child);
      return null;
    }

    return if (child != null) {
      if (child.getComponent() == component) {
        if (child.slot != slot) child.updateSlot(slot);
        child;
      } else if (child.getComponent().shouldBeUpdated(component)) {
        if (child.slot != slot) child.updateSlot(slot);
        child.update(component);
        child;
      } else {
        destroy(child);
        create(component, slot);
      }
    } else {
      create(component, slot);
    }
  }

  public function destroy(child:Element) {
    child.dispose();
  }
}
