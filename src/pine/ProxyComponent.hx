package pine;

import pine.internal.Debug;
import pine.signal.*;

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
        error('Component has more than one objects');
      }
      object = childComponent.getObject();
      true;
    });

    if (object == null) {
      error('Could not resolve an object');
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

  function addEffect(handler:()->Null<()->Void>) {
    onMount(() -> addImmediateEffect(handler));
  }

  function addImmediateEffect(handler:()->Null<()->Void>) {
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
}
