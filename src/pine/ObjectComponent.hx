package pine;

import haxe.ds.Option;
import pine.debug.Debug;
import pine.adaptor.*;
import pine.element.*;
import pine.element.ElementEngine;
import pine.hydration.Cursor;
import pine.diffing.Engine;

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

function useObjectElementEngine<T:ObjectComponent>(render, ?findApplicator, ?createObject):CreateElementEngine {
  return element -> new ObjectElementEngine<T>(element, render, findApplicator, createObject);
}

function defaultFindApplicator<T:ObjectComponent>(element:ElementOf<T>) {
  return element
    .getAdaptor()
    .orThrow('No Adaptor found')
    .getObjectApplicator(element.component.getObjectType());
}

function defaultCreateObject<T:ObjectComponent>(applicator:ObjectApplicator<Dynamic>, component:T) {
  return applicator.create(component);
}

class ObjectElementEngine<T:ObjectComponent> implements ElementEngine {
  final element:ElementOf<T>;
  final render:(element:ElementOf<T>)->Null<Array<Component>>;
  final findApplicator:(element:ElementOf<T>)->ObjectApplicator<Dynamic>;
  final createObject:(applicator:ObjectApplicator<Dynamic>, component:T)->Dynamic;
  
  var object:Null<Dynamic> = null;
  var children:Array<Element> = [];
  var previousComponent:Null<T> = null;
  
  public function new(element, render, ?findApplicator, ?createObject) {
    this.element = element;
    this.render = render;
    this.findApplicator = findApplicator == null 
      ? defaultFindApplicator
      : findApplicator;
    this.createObject = createObject == null
      ? defaultCreateObject
      : createObject;
  }

  public function init():Void {
    var applicator = findApplicator(element);

    Debug.assert(object == null);
    object = createObject(applicator, element.component);
    applicator.insert(object, element.slot, findAncestorObject);

    update();
  }

  public function hydrate(cursor:Cursor):Void {
    var applicator = findApplicator(element);

    Debug.assert(object == null);
    object = cursor.current();
    Debug.assert(object != null);
    applicator.update(object, element.component, null);

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
    var applicator = findApplicator(element);

    Debug.assert(object != null);
    applicator.update(object, element.component, previousComponent);
    previousComponent = element.component;
    
    children = diffChildren(element, children, renderSafe());
  }

  public function getObject():Dynamic {
    Debug.assert(object != null);
    return object;
  }

  public function createSlot(index:Int, previous:Null<Element>):Slot {
    return new Slot(index, previous);
  }

  public function updateSlot(newSlot:Null<Slot>):Void {
    var oldSlot = element.slot;
    element.slot = newSlot;

    if (object != null) {
      var applicator = findApplicator(element);
      applicator.move(object, oldSlot, newSlot, findAncestorObject);
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

  public function dispose() {
    for (child in children) child.dispose();
    children = [];

    if (object != null) {
      var applicator = findApplicator(element);
      applicator.remove(object, element.slot);
    }
    
    object = null;
    previousComponent = null;
  }

  function renderSafe() {
    var components = render(element);
    if (components == null) return [];
    return components.filter(e -> e != null);
  }

  function findAncestorObject() {
    return element
      .queryAncestors()
      .ofType(ObjectComponent)
      .orThrow('No ancestor object exists')
      .getObject();
  }
}
