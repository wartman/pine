package pine.element;

import pine.adaptor.Adaptor;
import pine.debug.Debug;
import pine.diffing.Engine;
import pine.element.ElementEngine;
import pine.hydration.Cursor;

typedef ProxyElementEngineOptions<T:Component> = {
  public final ?findObject:(element:ElementOf<T>)->Dynamic;
  public final ?findAdaptor:(element:ElementOf<T>)->Adaptor;
  public final ?handleThrownObject:(element:ElementOf<T>, target:Element, e:Dynamic)->Void;
} 

function useProxyElementEngine<T:Component>(render, ?options:ProxyElementEngineOptions<T>):CreateElementEngine {
  if (options == null) options = {};
  return element -> new ProxyElementEngine<T>(element, render, options);
}

function findChildObject(element:Element):Dynamic {
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
  Debug.assert(parent != null, 'Cannot resolve an adaptor as this element has no parent');
  return parent.getAdaptor();
}

function bubbleThrownObjectUp<T:Component>(element:ElementOf<T>, target:Element, e:Dynamic) {
  switch element.getParent() {
    case Some(parent): parent.engine.handleThrownObject(target, e);
    case None: throw e;
  }
}

class ProxyElementEngine<T:Component> implements ElementEngine {
  final element:ElementOf<T>;
  final render:(element:ElementOf<T>)->Null<Component>;
  final findObject:(element:ElementOf<T>)->Dynamic;
  final findAdaptor:(element:ElementOf<T>)->Adaptor;
  final errorHandler:(element:ElementOf<T>, target:Element, e:Dynamic)->Void;
  
  var child:Null<Element> = null;

  public function new(element, render, options:ProxyElementEngineOptions<T>) {
    this.element = element;
    this.render = render;
    this.findObject = options.findObject ?? findChildObject;
    this.findAdaptor = options.findAdaptor ?? findParentAdaptor;
    this.errorHandler = options.handleThrownObject ?? bubbleThrownObjectUp;
  }

  public function init():Void {
    child = renderSafe(element).createElement();
    child.mount(element, element.slot);
  }

  public function hydrate(cursor:Cursor):Void {
    // @todo: Think up a way to recover from hydration errors.
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

  public function handleThrownObject(target:Element, e:Dynamic) {
    errorHandler(element, target, e);
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
