package pine;

class ObserverElement extends ProxyElement {
  var observer:Null<Observer> = null;
  var result:Null<Component> = null;

  override function performHydrate(cursor:HydrationCursor) {
    setupObserver();

    if (result == null) {
      result = proxy.render(this);
    }

    child = hydrateElementForComponent(cursor, result, slot);
  }

  override function performBuild(previousComponent:Null<Component>) {
    if (previousComponent == null || observer == null) {
      setupObserver();
    }

    if (result == null) {
      result = proxy.render(this);
    }

    child = updateChild(child, result, slot);
  }

  function setupObserver() {
    var first = true;
    observer = new Observer(() -> {
      result = proxy.render(this);
      if (!first) {
        invalidate();
      } else {
        first = false;
      }
    });
  }

  override function dispose() {
    super.dispose();
    if (observer != null) {
      observer.dispose();
      observer = null;
    }
  }
}
