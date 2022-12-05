package pine.element.object;

import pine.hydration.Cursor;
import pine.diffing.Engine;
import pine.debug.Debug;
import pine.element.core.CoreChildrenQuery;

class DirectChildrenManager implements ChildrenManager {
  final element:Element;
  final render:(context:Context)->Array<Component>;

  var children:Array<Element> = [];
  var query:Null<ChildrenQuery> = null;

  public function new(element, render, ?options) {
    this.element = element;
    this.render = render;
  }

  public function init() {
    update();
  }

  public function hydrate(cursor:Cursor) {
    var components = renderSafe();
    var children:Array<Element> = [];
    var previous:Null<Element> = null;
    var cursorChildren = cursor.currentChildren();

    for (i in 0...components.length) {
      var component = components[i];
      if (component == null) continue;
      var child = component.createElement();
      child.hydrate(cursorChildren, element, element.slots.create(i, previous));
      children.push(child);
      previous = child;
    }

    Debug.assert(cursorChildren.current() == null);

    this.children = children;
  }

  public function update() {
    children = diffChildren(element, children, renderSafe());
  }

  public function visit(visitor:(child:Element) -> Bool) {
    for (child in children) {
      if (!visitor(child)) break;
    }
  }

  public function getQuery():ChildrenQuery {
    if (query == null) query = new CoreChildrenQuery(element);
    return query;
  }

  public function dispose() {
    for (child in children) child.dispose();
    children = [];
    query = null;
  }

  function renderSafe() {
    return render(element).filter(e -> e != null);
  }
}
