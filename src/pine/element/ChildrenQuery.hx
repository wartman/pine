package pine.element;

import haxe.ds.Option;

interface ChildrenQuery {
  public function filter(match:(child:Element) -> Bool, recursive:Bool = false):Array<Element>;
  public function find(match:(child:Element) -> Bool, recursive:Bool = false):Option<Element>;
  public function filterOfType<T:Component>(kind:Class<T>, recursive:Bool = false):Array<ElementOf<T>>;
  public function findOfType<T:Component>(kind:Class<T>, recursive:Bool = false):Option<ElementOf<T>>;
}
