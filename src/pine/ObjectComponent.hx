package pine;

import pine.internal.Debug;
import pine.internal.Reconcile;
import pine.object.ObjectHost;
import pine.signal.*;
import pine.signal.Signal;

abstract class ObjectComponent extends Component implements ObjectHost {
  var object:Null<Dynamic> = null;
  
  public function initialize() {
    initializeObject();
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
      if (signal == null) continue;
      Reflect.setField(obj, name, signal.peek());
    }
    return obj;
  }

  public function observeAttributeChanges(component:Component) {
    inline function applyAttribute(name:String, signal:ReadonlySignal<Any>) {
      var value = signal.get();
      switch component.componentLifecycleStatus {
        case Hydrating(_):
          component.getAdaptor().updateObjectAttribute(component.getObject(), name, value, true);
        default:
          component.getAdaptor().updateObjectAttribute(component.getObject(), name, value);
      }
    }
    for (name => signal in this) {
      if (signal == null) continue;
      if (signal.isInactive()) {
        // If the signal is inactive, avoid observing it.
        applyAttribute(name, signal);
      } else {
        // Otherwise wrap it in an observer.
        var observer = new Observer(() -> applyAttribute(name, signal));
        component.addDisposable(observer);
      }
    }
  }
}

abstract class ObjectWithChildrenComponent extends ObjectComponent {
  abstract function getName():String;

  abstract function getAttributes():Attributes;

  abstract function getChildren():ReadonlySignal<Array<Component>>;

  function initializeObject() {
    assert(adaptor != null);
    assert(object == null);

    var attributes = getAttributes(); 

    switch componentLifecycleStatus {
      case Hydrating(cursor):
        object = cursor.current();
      default:
        object = getAdaptor().createElementObject(getName(), attributes.getInitialAttrs());
        getAdaptor().insertObject(object, slot, findNearestObjectHostAncestor);
    }
    
    attributes.observeAttributeChanges(this);

    var prevChildren:Array<Component> = [];
    Observer.track(() -> {
      assert(componentBuildStatus != Building);
      assert(componentLifecycleStatus != Disposed);

      if (componentLifecycleStatus == Disposing) return;

      var newChildren = getChildren().get().filter(c -> c != null);

      switch componentLifecycleStatus {
        case Hydrating(cursor):
          componentBuildStatus = Building;
          var childCursor = cursor.currentChildren();
          prevChildren = hydrateChildren(this, childCursor, newChildren);
          assert(childCursor.current() == null, 'Hydration failed: too many children');
          cursor.next();
        default:
          componentBuildStatus = Building;
          prevChildren = reconcileChildren(this, prevChildren, newChildren);
      }

      componentBuildStatus = Built;
    });
    addDisposable(() -> prevChildren.resize(0));
  }

  public function visitChildren(visitor:(child:Component) -> Bool) {
    for (child in getChildren().peek()) {
      if (child == null) continue;
      if (!visitor(child)) return;
    }
  }
}

abstract class ObjectWithoutChildrenComponent extends ObjectComponent {
  abstract function getName():String;

  abstract function getAttributes():Attributes;

  function initializeObject() {
    assert(object == null);

    var attributes = getAttributes(); 

    switch componentLifecycleStatus {
      case Hydrating(cursor):
        object = cursor.current();
        attributes.observeAttributeChanges(this);
        cursor.next();
      default:
        object = getAdaptor().createElementObject(getName(), attributes.getInitialAttrs());
        getAdaptor().insertObject(object, slot, findNearestObjectHostAncestor);
        attributes.observeAttributeChanges(this);
    }

    componentBuildStatus = Built;
  }

  public function visitChildren(visitor:(child:Component) -> Bool) {
    // noop
  }
}
