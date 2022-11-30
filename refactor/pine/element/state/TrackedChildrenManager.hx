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
      if (computation == null) computation = createComputation(render);
      computation.peek();
    });
  }

  function createComputation(render:(context:Context)->Component) {
    return new Computation(() -> {
      var component = render(element);
      switch element.status {
        case Pending | Building:
        default: element.invalidate();
      }
      return component;
    });
  }

  override function dispose() {
    super.dispose();
    if (computation != null) {
      computation.dispose();
      computation = null;
    }
  }
}
