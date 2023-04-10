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
    status = Valid;
  }

  function getObject():Dynamic {
    return object;
  }

  function teardownObject() {
    if (object != null) {
      getAdaptor()?.removeObject(object, slot);
      object = null;
    }
  }

  override function updateSlot(?newSlot:Slot) {
    if (slot == newSlot) return;
    var prevSlot = slot;
    super.updateSlot(newSlot);
    getAdaptor()?.moveObject(getObject(), prevSlot, slot, findNearestObjectHostAncestor);
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
        component.getAdaptor()?.updateObjectAttribute(component.getObject(), name, value);
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

    object = adaptor?.createElementObject(getName(), attributes.getInitialAttrs());
    adaptor?.insertObject(object, slot, findNearestObjectHostAncestor);
    attributes.observeAttributeChanges(this);

    var prevChildren:Array<Component> = [];
    var childrenObserver = new Observer(() -> {
      assert(status != Building);
      assert(status != Disposed);

      if (status == Disposing) return;

      status = Building;
      prevChildren = reconcileChildren(this, prevChildren, getChildren().get());
      status = Valid;
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
    assert(adaptor != null);
    assert(object == null);

    var attributes = getAttributes(); 

    object = adaptor?.createElementObject(getName(), attributes.getInitialAttrs());
    adaptor?.insertObject(object, slot, findNearestObjectHostAncestor);
    attributes.observeAttributeChanges(this);
  }

  public function visitChildren(visitor:(child:Component) -> Bool) {}
}
