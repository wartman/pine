package pine.element.object;

import pine.element.core.CoreSlotManager;

class FragmentSlotManager extends CoreSlotManager {
  override function create(localIndex:Int, previous:Null<Element>):Slot {
    var parentSlot = element.slots.get();
    var index = parentSlot == null ? 0 : parentSlot.index;
    return new FragmentSlot(index, localIndex, previous);
  }
}

class FragmentSlot extends Slot {
  public final localIndex:Int;

  public function new(index, localIndex, previous) {
    super(index, previous);
    this.localIndex = localIndex;
  }

  override function indexChanged(other:Slot):Bool {
    if (other.index != index)
      return true;
    if (other is FragmentSlot) {
      var otherFragment:FragmentSlot = cast other;
      return localIndex != otherFragment.localIndex;
    }
    return false;
  }
}
