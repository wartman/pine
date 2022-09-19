package pine;

import pine.internal.*;

class ObserverElement extends Element {
  final child:SingleChildManager;
  var trackedObject:Null<Dynamic> = null;
  var computedRender:Null<Computation<Component>> = null;
  
  var observerComponent(get, never):ObserverComponent;
  inline function get_observerComponent():ObserverComponent {
    return getComponent();
  }

  public function new(component:ObserverComponent) {
    super(component);
    child = new SingleChildManager(
      () -> {
        if (computedRender == null) {
          computedRender = createRenderComputation();
        }
        return computedRender.get();
      },
      new ElementFactory(this)
    );
  }

  function performHydrate(cursor:HydrationCursor) {
    trackedObject = observerComponent.createTrackedObject();
    observerComponent.init(this);
    child.hydrate(cursor, slot);
  }

  function performBuild(previousComponent:Null<Component>) {
    if (previousComponent == null || trackedObject == null) {
      trackedObject = observerComponent.createTrackedObject();
    } else if (previousComponent != component) {
      observerComponent.reuseTrackedObject(trackedObject);
    }

    if (previousComponent == null) {
      observerComponent.init(this);
    }

    child.update(previousComponent, slot);
  }
  
  function performUpdateSlot(?slot:Slot) {
    child.update(slot); 
  }

  function createRenderComputation() {
    Debug.assert(computedRender == null);
    Debug.assert(status == Building, '`createRenderComputation` should ONLY be called from `performHydrate` or `performBuild`');
    
    return new Computation(() -> {
      var result = observerComponent.render(this);
      if (status != Building) invalidate();
      return result;
    });
  }

  function performDispose() {
    if (computedRender != null) {
      computedRender.dispose();
      computedRender = null;
    }
    child.dispose();
  }

  public function visitChildren(visitor:ElementVisitor) {
    child.visit(visitor);
  }
}
