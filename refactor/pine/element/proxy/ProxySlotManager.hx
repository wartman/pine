package pine.element.proxy;

class ProxySlotManager implements SlotManager {
  final element:Element;

  var slot:Null<Slot> = null;

  public function new(element) {
    this.element = element;
  }

  public function create(index:Int, previous:Null<Element>):Slot {
    return new Slot(index, previous);
  }

  public function get():Null<Slot> {
    return slot;
  }

  public function update(slot:Slot) {
    this.slot = slot;
    element.visitChildren(child -> {
      child.updateSlot(slot);
      true;
    });
  }

  public function equals(otherSlot:Slot) {
    return slot == otherSlot;
  }

  public function dispose() {
    slot = null;
  }
}
