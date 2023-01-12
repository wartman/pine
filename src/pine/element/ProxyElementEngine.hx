package pine.element;

import pine.core.PineElementException;
import pine.core.PineException;
import pine.adaptor.Adaptor;
import pine.debug.Debug;
import pine.diffing.Engine;
import pine.element.ElementEngine;
import pine.hydration.Cursor;

typedef ProxyElementEngineOptions<T:Component> = {
  public final ?findObject:(element:ElementOf<T>)->Dynamic;
  public final ?findAdaptor:(element:ElementOf<T>)->Adaptor;
} 

function useProxyElementEngine<T:Component>(render, ?options:ProxyElementEngineOptions<T>):CreateElementEngine {
  if (options == null) options = {};
  return element -> new ProxyElementEngine<T>(element, render, options);
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

function findParentAdaptor(element:Element):Adaptor {
  var parent = element.parent;
  if (parent == null) {
    throw new PineElementException(element, 'Cannot resolve an adaptor as this element has no parent');
  }
  Debug.assert(parent.adaptor != null);
  return parent.adaptor;
}

class ProxyElementEngine<T:Component> implements ElementEngine {
  final element:ElementOf<T>;
  final render:(element:ElementOf<T>)->Component;
  final findObject:(element:ElementOf<T>)->Dynamic;
  final findAdaptor:(element:ElementOf<T>)->Adaptor;
  
  var child:Null<Element> = null;

  public function new(element, render, options:ProxyElementEngineOptions<T>) {
    this.element = element;
    this.render = render;
    this.findObject = options.findObject != null
      ? options.findObject
      : findChildObject;
    this.findAdaptor = options.findAdaptor != null
      ? options.findAdaptor
      : findParentAdaptor;
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

  public function getAdaptor():Adaptor {
    return findAdaptor(element);
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
