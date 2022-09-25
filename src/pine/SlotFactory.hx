package pine;

interface SlotFactory {
  public function create(index:Int, previous:Null<Element>):Slot;
}
