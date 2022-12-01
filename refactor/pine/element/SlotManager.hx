package pine.element;

import pine.core.Disposable;

interface SlotManager extends Disposable {
  public function create(index:Int, previous:Null<Element>):Slot;
  public function get():Null<Slot>;
  public function init(slot:Null<Slot>):Void;
  public function update(slot:Null<Slot>):Void;
  public function equals(otherSlot:Null<Slot>):Bool;
}
