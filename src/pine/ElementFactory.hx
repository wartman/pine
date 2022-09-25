package pine;

interface ElementFactory {
  public function create(component:Component, ?slot:Slot):Element;
  public function hydrate(cursor:HydrationCursor, component:Component, ?slot:Slot):Element;
  public function update(?child:Element, ?component:Component, ?slot:Slot):Null<Element>;
  public function destroy(child:Element):Void;
}
