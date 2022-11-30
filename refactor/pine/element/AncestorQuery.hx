package pine.element;

import haxe.ds.Option;

interface AncestorQuery {
  public function ofType<T:Component>(kind:Class<T>):Option<ElementOf<T>>;
  public function find(match:(element:Element)->Bool):Option<Element>;
}
