package pine.element;

import pine.core.Disposable;
import pine.Component;
import pine.debug.Debug;
import pine.element.ElementEngine;
import pine.state.*;

function useTrackedProxyEngine<T:Component>(render:(element:ElementOf<T>)->Component):CreateElementEngine {
  var computation:Null<Computation<Component>> = null;
  var isUpdating:Bool = false;

  return (element:ElementOf<T>) -> new ProxyElementEngine<T>(element, element -> {
    if (computation != null) return computation.peek();

    element.watchLifecycle({
      beforeUpdate: (_, _, _) -> {
        isUpdating = true;
        if (computation != null) computation.revalidate();
      },
      afterUpdate: _ -> {
        isUpdating = false;
      },
      beforeDispose: _ -> {
        if (computation != null) {
          computation.dispose();
          computation = null;
        }
      }
    });

    computation = new Computation(() -> {
      var component = render(element);
      switch element.status {
        case Building if (isUpdating):
          // This means we're updating or initializing and the Computation
          // has been revalidated, so this is expected.
        case Disposing | Disposed:
          Debug.warn(
            'A pine.Signal was changed when an element was not Disposed or Disposing.'
            + ' Check your components and make sure you aren\'t updating'
            + ' Signals directly in a render method, after an element'
            + ' has been disposed, *or* before it has been initialized.'
          );
        default: 
          element.invalidate();
      }
      return component;
    });

    computation.peek();
  }, {});
}

typedef TrackedObjectOptions<T:Component, O:Disposable> = {
  public function init(component:T):O;
  public function bind(component:T, trackedObject:O):Void;
}

function useSyncedTrackedProxyEngine<T:Component, O:Disposable>(
  render:(element:ElementOf<T>)->Component,
  options:TrackedObjectOptions<T, O>
):CreateElementEngine {
  return (element:ElementOf<T>) -> {
    var factory = useTrackedProxyEngine(render);
    var tracked:Null<O> = null;

    element.watchLifecycle({
      beforeInit: (element, _) -> {
        Debug.assert(tracked == null);
        tracked = options.init(element.component);
      },
      beforeUpdate: (element, currentComponent, incomingComponent) -> {
        if (currentComponent == incomingComponent) return;
        Debug.assert(tracked != null);
        options.bind(incomingComponent, tracked);
      },
      beforeDispose: _ -> {
        if (tracked != null) {
          tracked.dispose();
          tracked = null;
        }
      }
    });

    factory(element);
  }
}
