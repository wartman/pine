package pine.element.core;

import pine.core.HasLazyProps;
import pine.hydration.Cursor;

class NoChildrenManager implements ChildrenManager implements HasLazyProps {
  final element:Element;

  @:lazy var query:ChildrenQuery = new ChildrenQuery(element);
  
  public function new(element) {
    this.element = element;
  }

  public function visit(visitor:(child:Element) -> Bool) {}

  public function init() {}

  public function hydrate(cursor:Cursor) {}

  public function update() {}

  public function getQuery():ChildrenQuery {
    return query;
  }

  public function dispose() {}
}