package pine.element.proxy;

import pine.diffing.Engine;
import pine.element.core.CoreChildrenQuery;
import pine.hydration.Cursor;

class ProxyChildrenManager implements ChildrenManager {
  final element:Element;
  final render:(context:Context)->Component;

  var child:Null<Element> = null;
  var query:Null<ChildrenQuery> = null;

  public function new(element, render) {
    this.element = element;
    this.render = render;
  }

  public function visit(visitor:(child:Element) -> Bool) {
    if (child != null) visitor(child);
  }

  public function init() {
    child = render(element).createElement();
    child.mount(element, element.slots.get());
  }

  public function hydrate(cursor:Cursor) {
    child = render(element).createElement();
    child.hydrate(cursor, element, element.slots.get());
  }

  public function update() {
    child = updateChild(element, child, render(element), element.slots.get());
  }

  public function getQuery():ChildrenQuery {
    if (query == null) query = new CoreChildrenQuery(element);
    return query;
  }

  public function dispose() {
    if (child != null) child.dispose();
    query = null;
  }
}
