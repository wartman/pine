package pine.element.object;

import pine.core.HasLazyProps;
import pine.hydration.Cursor;
import pine.diffing.Engine;

using pine.core.OptionTools;

/**
  Manage children that are not directly children of the
  parent component.
**/
class FragmentChildrenManager<T:Component>
  implements ChildrenManager
  implements HasLazyProps
{
  final element:Element;
  final render:(element:ElementOf<T>)->Array<Component>;

  var children:Array<Element> = [];
  var marker:Element;
  @:lazy var query:ChildrenQuery = new ChildrenQuery(element);

  public function new(element, render) {
    this.element = element;
    this.render = render;
    marker = createMarker();
  }

  public function init() {
    var slot = element.slots.get();
    var previous:Null<Element> = slot != null ? slot.previous : null;

    marker.mount(element, element.slots.create(0, previous));
    
    var previous = marker;
    var components = renderSafe();
    var newChildren:Array<Element> = [];
    for (i in 0...components.length) {
      var component = components[i];
      var child = component.createElement();
      child.mount(element, element.slots.create(i + 1, previous));
      newChildren.push(child);
      previous = child;
    }

    this.children = newChildren;
  }

  public function hydrate(cursor:Cursor) {
    var slot = element.slots.get();
    var previous:Null<Element> = slot != null ? slot.previous : null;

    marker.mount(element, element.slots.create(0, previous));

    var previous = marker;
    var components = renderSafe();
    var newChildren:Array<Element> = [];
    for (i in 0...components.length) {
      var component = components[i];
      var child = component.createElement();
      child.hydrate(cursor, element, element.slots.create(i + 1, previous));
      newChildren.push(child);
      previous = child;
    }

    this.children = newChildren;
  }

  public function update() {
    var currentSlot = element.slots.get();
    if (currentSlot != null) marker.updateSlot(currentSlot);
    children = diffChildren(element, children, renderSafe());
  }
  
  public function visit(visitor:(child:Element) -> Bool) {
    visitor(marker);
    for (child in children) visitor(child);
  }

  public function getQuery():ChildrenQuery {
    return query;
  }

  public function dispose() {
    marker.dispose();
    for (child in children) child.dispose();
    children = [];
  }

  function createMarker() {
    return element
      .adaptor
      .get()
      .sure()
      .createPlaceholder()
      .createElement();
  }

  function renderSafe() {
    return render(element).filter(e -> e != null);
  }
}
