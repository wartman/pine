package pine;

import kit.Assert;
import pine.internal.ObjectHost;
import pine.internal.Reconcile;
import pine.signal.*;
import pine.signal.Signal;

abstract class ObjectComponent extends Component implements ObjectHost {
  var object:Null<Dynamic> = null;
  
  public function initialize() {
    initializeObject();
    status = Built;
  }

  function getObject():Dynamic {
    return object;
  }

  function teardownObject() {
    if (object != null) {
      getAdaptor().removeObject(object, slot);
      object = null;
    }
  }

  override function updateSlot(?newSlot:Slot) {
    if (slot == newSlot) return;
    var prevSlot = slot;
    super.updateSlot(newSlot);
    getAdaptor().moveObject(getObject(), prevSlot, slot, findNearestObjectHostAncestor);
  }

  override function dispose() {
    teardownObject();
    super.dispose();
  }
}

@:forward
abstract Attributes(Map<String, ReadonlySignal<Any>>) from Map<String, ReadonlySignal<Any>> {
  public inline function new(attributes) {
    this = attributes;
  }

  public function getInitialAttrs():{} {
    var obj:{} = {};
    for (name => signal in this) {
      Reflect.setField(obj, name, signal.peek());
    }
    return obj;
  }

  public function observeAttributeChanges(component:Component) {
    for (name => signal in this) {
      component.effect(() -> {
        var value = signal.get();
        switch component.status {
          case Initializing(Hydrating(_)):
            component.getAdaptor().updateObjectAttribute(component.getObject(), name, value, true);
          default:
            component.getAdaptor().updateObjectAttribute(component.getObject(), name, value);
        }
        null;
      });
    }
  }
}

abstract class ElementWithChildrenComponent extends ObjectComponent {
  abstract function getName():String;

  abstract function getAttributes():Attributes;

  abstract function getChildren():ReadonlySignal<Array<Component>>;

  function initializeObject() {
    assert(adaptor != null);
    assert(object == null);

    var attributes = getAttributes(); 

    switch status {
      case Initializing(Hydrating(cursor)):
        object = cursor.current();
      default:
        object = getAdaptor().createElementObject(getName(), attributes.getInitialAttrs());
        getAdaptor().insertObject(object, slot, findNearestObjectHostAncestor);
    }
    
    attributes.observeAttributeChanges(this);

    var prevChildren:Array<Component> = [];
    var childrenObserver = new Observer(() -> {
      assert(status != Building);
      assert(status != Disposed);

      if (status == Disposing) return;

      var newChildren = getChildren().get();

      switch status {
        case Initializing(Hydrating(cursor)):
          status = Building;
          var childCursor = cursor.currentChildren();
          prevChildren = hydrateChildren(this, childCursor, newChildren);
          assert(childCursor.current() == null);
          cursor.next();
        default:
          status = Building;
          prevChildren = reconcileChildren(this, prevChildren, newChildren);
      }

      status = Built;
    });
    addDisposable(childrenObserver);
    addDisposable(() -> prevChildren.resize(0));
  }

  public function visitChildren(visitor:(child:Component) -> Bool) {
    for (child in getChildren().peek()) if (!visitor(child)) break;
  }
}

abstract class ElementWithoutChildrenComponent extends ObjectComponent {
  abstract function getName():String;

  abstract function getAttributes():Attributes;

  function initializeObject() {
    assert(object == null);

    var attributes = getAttributes(); 

    switch status {
      case Initializing(Hydrating(cursor)):
        object = cursor.current();
        attributes.observeAttributeChanges(this);
        cursor.next();
      default:
        object = getAdaptor().createElementObject(getName(), attributes.getInitialAttrs());
        getAdaptor().insertObject(object, slot, findNearestObjectHostAncestor);
        attributes.observeAttributeChanges(this);
    }
  }

  public function visitChildren(visitor:(child:Component) -> Bool) {
    // noop
  }
}
