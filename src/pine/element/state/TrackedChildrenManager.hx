package pine.element.state;

import pine.state.*;
import pine.debug.Debug;
import pine.element.proxy.ProxyChildrenManager;

/**
  Use the TrackedChildrenManager to automatically react to state
  changes in a `render` method.
**/
class TrackedChildrenManager<T:Component> extends ProxyChildrenManager<T> {
  var computation:Null<Computation<Component>> = null;
  var isUpdating:Bool = false;

  public function new(element, render) {
    super(element, context -> {
      if (computation == null) computation = new Computation(() -> {
        var component = render(context);
        switch element.status {
          case Building if (isUpdating):
            // This means we're updating or initializing and the Computation
            // has been revalidated, so this is expected.
          case Valid: 
            element.invalidate();
          default:
            // @todo: This might be fine, actually? Need to think
            // some more on how things are ordered.
            Debug.warn(
              'A pine.Signal was changed when an element was not Valid.'
              + ' Check your components and make sure you aren\'t updating'
              + ' Signals directly in a render method, after an element'
              + ' has been disposed, *or* before it has been initialized.'
            );
        }
        return component;
      });
      computation.peek();
    });
  }

  override function init() {
    isUpdating = true;
    super.init();
    isUpdating = false;
  }

  override function update() {
    isUpdating = true;
    if (computation != null) computation.revalidate();
    super.update();
    isUpdating = false;
  }

  override function dispose() {
    if (computation != null) {
      computation.dispose();
      computation = null;
    }
    super.dispose();
  }
}
