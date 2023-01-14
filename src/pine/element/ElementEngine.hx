package pine.element;

import pine.adaptor.Adaptor;
import pine.core.Disposable;
import pine.hydration.Cursor;

typedef CreateElementEngine = (element:Element)->ElementEngine;

interface ElementEngine extends Disposable {
  public function init():Void;
  public function hydrate(cursor:Cursor):Void;
  public function update():Void;
  public function getAdaptor():Adaptor;
  public function getObject():Dynamic;
  public function createSlot(index:Int, previous:Null<Element>):Slot;
  public function updateSlot(slot:Null<Slot>):Void;
  public function visitChildren(visitor:(child:Element)->Bool):Void;
  public function createChildrenQuery():ChildrenQuery;
  public function createAncestorQuery():AncestorQuery;
  public function handleError(target:Element, e:Dynamic):Void;
}
