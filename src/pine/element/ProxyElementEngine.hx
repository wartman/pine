package pine.element;

import pine.debug.Debug;
import pine.diffing.Engine;
import pine.element.ElementEngine;
import pine.hydration.Cursor;

function useProxyElementEngine<T:Component>(render, ?findObject):CreateElementEngine {
  return element -> new ProxyElementEngine<T>(element, render, findObject);
}

function findChildObject(element:Element) {
  var object:Null<Dynamic> = null;

  element.visitChildren(element -> {
    Debug.assert(object == null, 'Element has more than one objects');
    object = element.getObject();
    
    true;
  });

  Debug.alwaysAssert(object != null, 'Element does not have an object');

  return object;
}

class ProxyElementEngine<T:Component> implements ElementEngine {
  final element:ElementOf<T>;
  final findObject:(element:ElementOf<T>)->Dynamic;
  final render:(element:ElementOf<T>)->Component;
  
  var child:Null<Element> = null;

  public function new(element, render, ?findObject) {
    this.element = element;
    this.render = render;
    this.findObject = findObject != null
      ? findObject
      : findChildObject;
  }

  public function init():Void {
    child = renderSafe(element).createElement();
    child.mount(element, element.slot);
  }

  public function hydrate(cursor:Cursor):Void {
    child = renderSafe(element).createElement();
    child.hydrate(cursor, element, element.slot);
  }
  
  public function update() {
    child = updateChild(element, child, renderSafe(element), element.slot);
  }

  public function getObject():Dynamic {
    return findObject(element);
  }

  public function createSlot(index:Int, previous:Null<Element>):Slot {
    return new Slot(index, previous);
  }

  public function updateSlot(slot:Null<Slot>):Void {
    element.slot = slot;
    visitChildren(child -> {
      child.updateSlot(slot);
      true;
    });
  }

  public function visitChildren(visitor:(child:Element)->Bool):Void {
    if (child != null) visitor(child);
  }

  public function createChildrenQuery():ChildrenQuery {
    return new ChildrenQuery(element);
  }

  public function createAncestorQuery():AncestorQuery {
    return new AncestorQuery(element);
  }

  public function dispose() {
    visitChildren(child -> {
      child.dispose();
      true;  
    });
  }
  
  function renderSafe(element:ElementOf<T>):Component {
    var component = render(element);
    if (component == null) return new Fragment({ children: [] });
    return component;
  }
}
