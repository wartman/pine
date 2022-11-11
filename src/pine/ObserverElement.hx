package pine;

@component(ObserverComponent)
class ObserverElement extends ProxyElement {
  var trackedObject:Null<Dynamic> = null;
  var computedRender:Null<Computation<Component>> = null;

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
    } else if (previousComponent != component) {
      computedRender.revalidate();
    }

    child = updateChild(child, computedRender.get(), slot);
  }

  function createRenderComputation() {
    Debug.assert(
      computedRender == null,
      '`createRenderComputation` was called more than once.'
    );
    Debug.assert(
      status == Building,
      '`createRenderComputation` should ONLY be called from `performHydrate` or `performBuild`'
    );
    
    return new Computation<Component>(() -> {
      Debug.assert(
        status != Disposing,
        'A computation was not disposed correctly and has been triggered '
        + 'during its element\'s disposal process. This will result in strange '
        + 'behavior and/or errors.'
      );
      var result = render();
      if (status != Building) invalidate();
      return result;
    });
  }

  override function prepareForDisposal() {
    if (computedRender != null) {
      computedRender.dispose();
      computedRender = null;
    }
    super.prepareForDisposal();
  }
}
