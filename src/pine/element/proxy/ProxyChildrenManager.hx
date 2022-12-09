package pine.element.proxy;

import pine.core.HasLazyProps;
import pine.diffing.Engine;
import pine.element.core.CoreChildrenQuery;
import pine.hydration.Cursor;

class ProxyChildrenManager 
  implements ChildrenManager
  implements HasLazyProps
{
  final element:Element;
  final render:(context:Context)->Component;

  var child:Null<Element> = null;
  @:lazy var query:ChildrenQuery = new CoreChildrenQuery(element);

  public function new(element, render) {
    this.element = element;
    this.render = render;
  }

  public function visit(visitor:(child:Element) -> Bool) {
    if (child != null) visitor(child);
  }

  public function init() {
    child = renderSafe(element).createElement();
    child.mount(element, element.slots.get());
  }

  public function hydrate(cursor:Cursor) {
    child = renderSafe(element).createElement();
    child.hydrate(cursor, element, element.slots.get());
  }

  public function update() {
    child = updateChild(element, child, renderSafe(element), element.slots.get());
  }

  public function getQuery():ChildrenQuery {
    return query;
  }

  public function dispose() {
    visit(child -> {
      child.dispose();
      true;
    });
  }

  function renderSafe(context:Context):Component {
    var component = render(context);
    if (component == null) return new Fragment({ children: [] });
    return component;
  }
}
