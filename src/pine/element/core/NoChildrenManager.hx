package pine.element.core;

import pine.hydration.Cursor;

class NoChildrenManager implements ChildrenManager {
  final element:Element;

  var query:Null<ChildrenQuery> = null;
  
  public function new(element) {
    this.element = element;
  }

  public function visit(visitor:(child:Element) -> Bool) {}

  public function init() {}

  public function hydrate(cursor:Cursor) {}

  public function update() {}

  public function getQuery():ChildrenQuery {
    if (query == null) query = new CoreChildrenQuery(element);
    return query;
  }

  public function dispose() {}
}