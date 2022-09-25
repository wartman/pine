package pine;

class DefaultSlotFactory implements SlotFactory {
  static public final instance = new DefaultSlotFactory();

  public function new() {}

  public function create(index:Int, previous:Null<Element>):Slot {
    return new Slot(index, previous);
  }
}
