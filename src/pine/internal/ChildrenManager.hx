package pine.internal;

interface ChildrenManager extends Disposable {
  public function hydrate(cursor:HydrationCursor, parent:Null<Element>, ?slot:Slot):Void;
  public function update(component:Component):Void;
  public function visit(visitor:ElementVisitor):Void;
}

