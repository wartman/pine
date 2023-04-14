package pine;

import kit.Assert;
import pine.signal.*;
import pine.signal.Signal;

using Kit;

abstract class ProxyComponent extends Component {
  var childComponent:Null<Component> = null;
  var onMountEffects:Array<()->Void> = [];

  abstract function build():Component;

  function initialize() {
    Observer.untrack(() -> {
      assert(componentLifecycleStatus != Disposed);
      assert(componentBuildStatus != Building);
      assert(childComponent == null);
      
      if (componentLifecycleStatus == Disposing) return;

      componentBuildStatus = Building;

      childComponent = build();
      if (childComponent == null) childComponent = new Placeholder();

      switch componentLifecycleStatus {
        case Hydrating(cursor):
          childComponent.hydrate(this, cursor, slot);
        default:
          childComponent.mount(this, slot);
      }

      var effects = onMountEffects;
      onMountEffects = [];
      for (e in effects) e();

      componentBuildStatus = Built;
    });
  }

  function getObject():Dynamic {
    var object:Null<Dynamic> = null;
      
    visitChildren(childComponent -> {
      if (object != null) {
        throw new PineException('Component has more than one objects');
      }
      object = childComponent.getObject();
      true;
    });

    if (object == null) {
      throw new PineException('Could not resolve an object');
    }

    return object;
  }

  override function updateSlot(?newSlot:Slot) {
    super.updateSlot(newSlot);
    visitChildren(childComponent -> {
      childComponent.updateSlot(newSlot);
      true;
    });
  }

  function visitChildren(visitor:(childComponent:Component)->Bool) {
    if (childComponent != null) visitor(childComponent);
  }

  inline function signal<T>(value:T):Signal<T> {
    return new Signal(value);
    // @todo: Should we dispose owned signals when the Component 
    // is disposed?
  }

  inline function compute<T>(compute):ReadonlySignal<T> {
    var computed = new Computation(compute);
    addDisposable(computed);
    return computed;
  }

  function effect(handler:()->Null<()->Void>) {
    onMount(() -> immediateEffect(handler));
  }

  function immediateEffect(handler:()->Null<()->Void>) {
    var cleanup:Null<()->Void> = null;
    var observer = new Observer(() -> {
      if (cleanup != null) {
        cleanup();
        cleanup = null;
      }
      switch componentLifecycleStatus {
        case Disposing | Disposed: return;
        default:
      }
      cleanup = handler();
    });
    addDisposable(() -> {
      observer.dispose();
      if (cleanup != null) {
        cleanup();
        cleanup = null;
      }
    });
  }

  inline function onMount(handler:()->Void) {
    onMountEffects.push(handler);
  }

  inline function onCleanup(handler:()->Void) {
    addDisposable(handler);
  }
}
