package pine;

class Slot {
  public final index:Int;
  public final previous:Null<View>;

  public function new(index, previous) {
    this.index = index;
    this.previous = previous;
  }

  public function indexChanged(other:Slot) {
    return index != other.index;
  }
}
