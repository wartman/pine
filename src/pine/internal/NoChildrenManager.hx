package pine.internal;

class NoChildrenManager implements ChildrenManager {
  public function new() {}

  public function hydrate(cursor:HydrationCursor, ?slot:Slot) {}
  
  public function update(?previousComponent:Component, ?slot:Slot) {}
  
  public function visit(visitor:ElementVisitor) {}
  
  public function dispose() {}
}
