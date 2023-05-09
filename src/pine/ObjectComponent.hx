package pine;

import pine.debug.Debug;
import pine.internal.*;
import pine.internal.Reconcile;
import pine.signal.Observer;
import pine.signal.Signal;

@:build(pine.macro.ReactiveObjectBuilder.build())
class ObjectComponent extends Component implements ObjectHost {
  final createObject:(adaptor:Adaptor, attrs:{})->Dynamic;
  final attributes:Map<String, ReadonlySignal<Any>>;
  final hasChildren:Bool = true;
  final children:Null<Children> = null;

  var object:Null<Dynamic> = null;

  public function initialize() {
    initializeObject();
    observeAttributeChanges();
    initializeChildren();
  }

  function getObject():Dynamic {
    assert(object != null);
    return object;
  }

  function initializeObject() {
    assert(object == null);

    var adaptor = getAdaptor();

    switch componentLifecycleStatus {
      case Hydrating(cursor):
        object = cursor.current();
        if (!hasChildren) cursor.next();
      default:
        object = createObject(adaptor, getInitialAttrs());
        adaptor.insertObject(object, slot, findNearestObjectHostAncestor);
    }
  }

  function disposeObject() {
    if (object != null) {
      getAdaptor().removeObject(object, slot);
      object = null;
    }
  }

  function initializeChildren() {
    if (!hasChildren) {
      assert(children == null, 'You should not have children if hasChildren is false');
      return;
    }

    var prevChildren:Array<Component> = [];
    Observer.track(() -> {
      assert(componentBuildStatus != Building);
      assert(componentLifecycleStatus != Disposed);

      if (componentLifecycleStatus == Disposing) return;

      var newChildren = children?.get()?.filter(c -> c != null) ?? [];

      componentBuildStatus = Building;
      
      switch componentLifecycleStatus {
        case Hydrating(cursor):
          var childCursor = cursor.currentChildren();
          prevChildren = hydrateChildren(this, childCursor, newChildren);
          assert(childCursor.current() == null, 'Hydration failed: too many children');
          cursor.next();
        default:
          prevChildren = reconcileChildren(this, prevChildren, newChildren);
      }

      componentBuildStatus = Built;
    });
    addDisposable(() -> prevChildren.resize(0));
  }

  public function visitChildren(visitor:(child:Component) -> Bool) {
    if (children == null) return;
    for (child in children.peek()) {
      if (child == null) continue;
      if (!visitor(child)) return;
    }
  }
  
  function getInitialAttrs() {
    var obj:{} = {};
    for (name => signal in attributes) {
      if (signal == null) continue;
      Reflect.setField(obj, name, signal.peek());
    }
    return obj;
  }

  function observeAttributeChanges() {
    inline function applyAttribute(name:String, signal:ReadonlySignal<Any>) {
      var value = signal.get();
      switch componentLifecycleStatus {
        case Hydrating(_):
          getAdaptor().updateObjectAttribute(getObject(), name, value, true);
        default:
          getAdaptor().updateObjectAttribute(getObject(), name, value);
      }
    }
    for (name => signal in attributes) {
      if (signal == null) continue;
      if (signal.isInactive()) {
        applyAttribute(name, signal);
      } else {
        Observer.track(() -> applyAttribute(name, signal));
      }
    }
  }

  override function updateSlot(?newSlot:Slot) {
    if (slot == newSlot) return;
    var prevSlot = slot;
    super.updateSlot(newSlot);
    getAdaptor().moveObject(getObject(), prevSlot, slot, findNearestObjectHostAncestor);
  }

  override function dispose() {
    disposeObject();
    super.dispose();
  }
}