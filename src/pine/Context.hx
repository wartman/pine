package pine;

import haxe.ds.Option;

interface Context {
  public function getRoot():Root;
  public function getObject():Dynamic;
  public function getComponent<T:Component>():Null<T>;
  public function isHydrating():Bool;
  public function findAncestorOfType<T:Element>(kind:Class<T>):Option<T>;
  public function queryAncestors(query:(parent:Element) -> Bool):Option<Element>;
  public function visitChildren(visitor:ElementVisitor):Void;
  public function queryChildren(query:(child:Element) -> Bool):Option<Array<Element>>;
  public function queryFirstChild(query:(child:Element) -> Bool):Option<Element>;
  public function findChildrenOfType<T:Element>(kind:Class<T>):Option<Array<T>>;
}
