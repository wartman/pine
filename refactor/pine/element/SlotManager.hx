package pine.element;

import pine.core.Disposable;

interface SlotManager extends Disposable {
  public function create(index:Int, previous:Null<Element>):Slot;
  public function get():Null<Slot>;
  public function update(slot:Slot):Void;
  public function equals(otherSlot:Slot):Bool;
}
