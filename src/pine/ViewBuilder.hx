package pine;

interface ViewBuilder {
  public function createView(parent:View, slot:Null<Slot>):View;
}
