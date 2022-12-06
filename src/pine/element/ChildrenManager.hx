package pine.element;

import pine.core.Disposable;
import pine.hydration.Cursor;

interface ChildrenManager extends Disposable {
  public function visit(visitor:(child:Element)->Bool):Void;
  public function init():Void;
  public function hydrate(cursor:Cursor):Void;
  public function update():Void;
  public function getQuery():ChildrenQuery;
}
