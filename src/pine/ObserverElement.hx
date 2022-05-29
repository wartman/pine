package pine;

class ObserverElement extends ProxyElement {
  var trackedObject:Null<Dynamic> = null;
  var observer:Null<Observer> = null;
  var result:Null<Component> = null;
  var observerComponent(get, never):ObserverComponent;

  inline function get_observerComponent():ObserverComponent {
    return cast component;
  }

  override function performHydrate(cursor:HydrationCursor) {
    trackedObject = observerComponent.createTrackedObject();
    observerComponent.init(this);

    setupObserver();

    Debug.alwaysAssert(result != null);
    child = hydrateElementForComponent(cursor, result, slot);
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

    if (observer == null) {
      setupObserver();
    } else if (previousComponent != component) {
      observer.trigger();
    }

    Debug.alwaysAssert(result != null);
    child = updateChild(child, result, slot);
  }

  function setupObserver() {
    Debug.assert(observer == null);
    Debug.assert(status == Building, '`setupObserver` should ONLY be called from `performHydrate` or `performBuild`');
    
    observer = new Observer(() -> {
      result = render();
      if (status != Building) invalidate();
    });
  }

  override function dispose() {
    super.dispose();
    result = null;
    if (observer != null) {
      observer.dispose();
      observer = null;
    }
  }
}
