package pine;

interface Builder {
  public function createView(parent:View, slot:Null<Slot>):View;
}
