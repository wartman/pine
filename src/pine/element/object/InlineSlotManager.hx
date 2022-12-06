package pine.element.object;

import pine.element.core.CoreSlotManager;

class InlineSlotManager extends CoreSlotManager {
  override function create(localIndex:Int, previous:Null<Element>):Slot {
    var parentSlot = element.slots.get();
    var index = parentSlot == null ? 0 : parentSlot.index;
    return new InlineSlot(index, localIndex, previous);
  }
}

class InlineSlot extends Slot {
  public final localIndex:Int;

  public function new(index, localIndex, previous) {
    super(index, previous);
    this.localIndex = localIndex;
  }

  override function indexChanged(other:Slot):Bool {
    if (other.index != index)
      return true;
    if (other is InlineSlot) {
      var otherFragment:InlineSlot = cast other;
      return localIndex != otherFragment.localIndex;
    }
    return false;
  }
}
