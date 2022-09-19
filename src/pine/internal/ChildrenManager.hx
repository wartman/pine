package pine.internal;

interface ChildrenManager extends Disposable {
  public function hydrate(cursor:HydrationCursor, ?slot:Slot):Void;
  public function update(?previousComponent:Component, ?slot:Slot):Void;
  public function updateSlot(?slot:Slot):Void;
  public function visit(visitor:ElementVisitor):Void;
}
