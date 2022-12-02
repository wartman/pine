package pine.element.state;

import pine.state.*;
import pine.element.proxy.ProxyChildrenManager;

/**
  Use the TrackedChildrenManager to automatically react to state
  changes in a `render` method.
**/
class TrackedChildrenManager extends ProxyChildrenManager {
  var computation:Null<Computation<Component>> = null;

  public function new(element, render) {
    super(element, context -> {
      if (computation == null) computation = new Computation(() -> {
        var component = render(context);
        switch element.status {
          case Pending | Building:
          default: element.invalidate();
        }
        return component;
      });
      computation.peek();
    });
  }

  override function update() {
    if (computation != null) {
      computation.revalidate();
    }
    super.update();
  }

  override function dispose() {
    if (computation != null) {
      computation.dispose();
      computation = null;
    }
    super.dispose();
  }
}
