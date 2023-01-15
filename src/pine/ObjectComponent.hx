package pine;

import pine.core.PineException;
import pine.adaptor.*;
import pine.debug.Debug;
import pine.diffing.Engine;
import pine.element.*;
import pine.element.ElementEngine;
import pine.element.ProxyElementEngine;
import pine.hydration.Cursor;

using pine.core.OptionTools;

abstract class ObjectComponent extends Component {
  abstract public function getObjectType():ObjectType;

  abstract public function getObjectData():Dynamic;

  abstract public function render():Null<Array<Component>>;

  public function createElement() {
    return new Element(
      this,
      useObjectElementEngine(
        (element:ElementOf<ObjectComponent>) -> element.component.render()
      ),
      []
    );
  }
}

typedef ObjectElementEngineOptions<T:ObjectComponent> = {
  public final ?findAdaptor:(element:ElementOf<T>)->Adaptor;
  public final ?createObject:(adaptor:Adaptor, element:ElementOf<T>)->Dynamic;
  public final ?destroyObject:(adaptor:Adaptor, element:ElementOf<T>, object:Dynamic)->Void;
  public final ?handleThrownObject:(element:ElementOf<T>, target:Element, e:Dynamic)->Void;
} 

function useObjectElementEngine<T:ObjectComponent>(render, ?options):CreateElementEngine {
  return element -> new ObjectElementEngine<T>(element, render, options);
}

function findAncestorObject(element:Element) {
  return element
    .queryAncestors()
    .ofType(ObjectComponent)
    .orThrow('No ancestor object exists')
    .getObject();
}

function defaultCreateObject<T:ObjectComponent>(adaptor:Adaptor, element:ElementOf<T>) {
  var type = element.component.getObjectType();
  var object = adaptor.createObject(type, element.component);
  adaptor.insertObject(type, object, element.slot, () -> findAncestorObject(element));
  return object;
}

function defaultDestroyObject<T:ObjectComponent>(adaptor:Adaptor, element:ElementOf<T>, object:Dynamic) {
  var type = element.component.getObjectType();
  adaptor.removeObject(type, object, element.slot);
}

class ObjectElementEngine<T:ObjectComponent> implements ElementEngine {
  final element:ElementOf<T>;
  final render:(element:ElementOf<T>)->Null<Array<Component>>;
  final findAdaptor:(element:ElementOf<T>)->Adaptor;
  final createObject:(adaptor:Adaptor, element:ElementOf<T>)->Dynamic;
  final destroyObject:(adaptor:Adaptor, element:ElementOf<T>, object:Dynamic)->Void;
  final errorHandler:(element:ElementOf<T>, target:Element, e:Dynamic)->Void;

  var object:Null<Dynamic> = null;
  var children:Array<Element> = [];
  var previousComponent:Null<T> = null;
  
  public function new(element, render, ?options:ObjectElementEngineOptions<T>) {
    if (options == null) options = {};
    
    this.element = element;
    this.render = render;
    this.createObject = options.createObject == null
      ? defaultCreateObject
      : options.createObject;
    this.destroyObject = options.destroyObject == null
      ? defaultDestroyObject
      : options.destroyObject;
    this.findAdaptor = options.findAdaptor == null
      ? findParentAdaptor
      : options.findAdaptor;
    this.errorHandler = options.handleThrownObject != null
      ? options.handleThrownObject
      : bubbleThrownObjectUp;
  }

  public function init():Void {
    var adaptor = getAdaptor();

    Debug.assert(object == null);
    object = createObject(adaptor, element);

    update();
  }

  public function hydrate(cursor:Cursor):Void {
    var adaptor = getAdaptor();
    var type = element.component.getObjectType();

    Debug.assert(object == null);
    object = cursor.current();
    Debug.assert(object != null);
    adaptor.updateObject(type, object, element.component, null);

    var components = renderSafe();

    var children:Array<Element> = [];
    var previous:Null<Element> = null;
    var cursorChildren = cursor.currentChildren();

    for (i in 0...components.length) {
      var component = components[i];
      if (component == null) continue;
      var child = component.createElement();
      child.hydrate(cursorChildren, element, createSlot(i, previous));
      children.push(child);
      previous = child;
    }

    Debug.assert(cursorChildren.current() == null);

    this.children = children;

    cursor.next();
  }

  public function update():Void {
    var adaptor = getAdaptor();
    var type = element.component.getObjectType();

    Debug.assert(object != null);
    adaptor.updateObject(type, object, element.component, previousComponent);
    previousComponent = element.component;
    
    children = diffChildren(element, children, renderSafe());
  }

  public function getObject():Dynamic {
    Debug.assert(object != null);
    return object;
  }

  public function getAdaptor():Adaptor {
    var adaptor = element.adaptor;
    if (adaptor != null) return adaptor;
    return findAdaptor(element);
  }

  public function createSlot(index:Int, previous:Null<Element>):Slot {
    return new Slot(index, previous);
  }

  public function updateSlot(newSlot:Null<Slot>):Void {
    var oldSlot = element.slot;
    element.slot = newSlot;

    if (object != null) {
      var adaptor = getAdaptor();
      var type = element.component.getObjectType();
      // @todo: I think this makes sense?
      if (newSlot == null) {
        adaptor.removeObject(type, object, oldSlot);
      } else {
        adaptor.moveObject(type, object, oldSlot, newSlot, () -> findAncestorObject(element));
      }
    }
  }

  public function visitChildren(visitor:(child:Element)->Bool):Void {
    for (child in children) {
      if (!visitor(child)) break;
    }
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
    for (child in children) child.dispose();
    children = [];

    if (object != null) {
      var adaptor = getAdaptor();
      destroyObject(adaptor, element, object);
    }
    
    object = null;
    previousComponent = null;
  }

  function renderSafe() {
    var components = render(element);
    if (components == null) return [];
    return components.filter(e -> e != null);
  }
}
