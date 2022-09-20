package pine;

class ElementFactory {
  final parent:Element;
  final slotFactory:(index:Int, previous:Null<Element>)->Slot;

  public function new(parent, ?slotFactory) {
    this.parent = parent;  
    this.slotFactory = slotFactory == null
      ? Slot.new
      : slotFactory;
  }

  public function createChild(component:Component, ?slot:Slot):Element {
    var element = component.createElement();
    element.mount(parent, slot);
    return element;
  }

  public function hydrateChild(cursor:HydrationCursor, component:Component, ?slot:Slot):Element {
    var element = component.createElement();
    element.hydrate(cursor, parent, slot);
    return element;
  }

  public function updateChild(?child:Element, ?component:Component, ?slot:Slot):Null<Element> {
    if (component == null) {
      if (child != null) destroyChild(child);
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
        destroyChild(child);
        createChild(component, slot);
      }
    } else {
      createChild(component, slot);
    }
  }

  public function destroyChild(child:Element) {
    child.dispose();
  }

  public function createSlot(index:Int, previous:Null<Element>):Slot {
    return slotFactory(index, previous);
  }
}
