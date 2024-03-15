package pine;

import pine.signal.Observer;

/**
  Register a callback that will run *once* after a View is mounted.
**/
function onMount(view:View, effect:()->Void):View {
  return new OnMountModifier(view, effect);
}

/**
  Register an effect that will be registered when the View is mounted
  and which can use an optional cleanup method.
**/
function withEffect(view:View, effect:()->Null<()->Void>) {
  var cleanup = null;
  var modifier = new OnMountModifier(view, () -> {
    Observer.track(() -> {
      if (cleanup != null) {
        cleanup();
        cleanup = null;
      }
      cleanup = effect();
    });
  });
  modifier.addDisposable(() -> {
    if (cleanup != null) {
      cleanup();
      cleanup = null;
    }
  });
  return modifier;
}

private class OnMountModifier extends ProxyView {
  final child:Child;
  final effect:()->Void;

  public function new(child, effect) {
    this.child = child;
    this.effect = effect;
  }

  function render():Child {
    return child;
  }

  override function __initialize() {
    super.__initialize();
    __owner.own(() -> this.effect());
  }
}
