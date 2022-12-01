package pine.element.core;

class CoreSlotManager implements SlotManager {
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

  public function init(slot:Null<Slot>) {
    this.slot = slot;
  }

	public function update(slot:Null<Slot>) {
    this.slot = slot;
  }

	public function equals(otherSlot:Slot):Bool {
    return slot == slot;
	}

	public function dispose() {
    slot = null;
  }
}
