package pine;

class ObserverElement extends ProxyElement {
  var trackedObject:Null<Dynamic> = null;
  var computedRender:Null<Computation<Component>> = null;
  var observerComponent(get, never):ObserverComponent;

  inline function get_observerComponent():ObserverComponent {
    return getComponent();
  }

  public function new(component:ObserverComponent) {
    super(component);
  }

  override function performHydrate(cursor:HydrationCursor) {
    trackedObject = observerComponent.createTrackedObject();
    observerComponent.init(this);

    if (computedRender == null) {
      computedRender = createRenderComputation();
    }

    child = hydrateElementForComponent(cursor, computedRender.get(), slot);
  }

  override function performBuild(previousComponent:Null<Component>) {
    if (previousComponent == null || trackedObject == null) {
      trackedObject = observerComponent.createTrackedObject();
    } else if (previousComponent != component) {
      observerComponent.reuseTrackedObject(trackedObject);
    }

    if (previousComponent == null) {
      observerComponent.init(this);
    }

    if (computedRender == null) {
      computedRender = createRenderComputation();
    }

    child = updateChild(child, computedRender.get(), slot);
  }

  function createRenderComputation() {
    Debug.assert(computedRender == null);
    Debug.assert(status == Building, '`setupObserver` should ONLY be called from `performHydrate` or `performBuild`');
    
    var ran = 0;
    return new Computation<Component>(() -> {
      var result = render();
      if (status != Building) invalidate();
      return result;
    });
  }

  override function dispose() {
    if (computedRender != null) {
      computedRender.dispose();
      computedRender = null;
    }
    super.dispose();
  }
}
