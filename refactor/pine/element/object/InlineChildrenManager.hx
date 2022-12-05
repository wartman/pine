package pine.element.object;

import pine.hydration.Cursor;
import pine.diffing.Engine;
import pine.element.core.CoreChildrenQuery;

using pine.core.OptionTools;

/**
  Manage children that are not directly children of the
  parent component (this is a Fragment, basically).
**/
class InlineChildrenManager implements ChildrenManager {
  final element:Element;
  final render:(context:Context)->Array<Component>;

  var children:Array<Element> = [];
  var marker:Element;
  var query:Null<ChildrenQuery> = null;

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
    marker.updateSlot(element.slots.get());
    children = diffChildren(element, children, renderSafe());
  }
  
  public function visit(visitor:(child:Element) -> Bool) {
    visitor(marker);
    for (child in children) visitor(child);
  }

  public function getQuery():ChildrenQuery {
    if (query == null) query = new CoreChildrenQuery(element);
    return query;
  }

  public function dispose() {
    marker.dispose();
    for (child in children) child.dispose();
    children = [];
  }

  function createMarker() {
    return element
      .adapter
      .get()
      .sure()
      .createPlaceholder()
      .createElement();
  }

  function renderSafe() {
    return render(element).filter(e -> e != null);
  }
}
