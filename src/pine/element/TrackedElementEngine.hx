package pine.element;

import pine.CoreHooks.beforeInit;
import pine.element.ProxyElementEngine.useProxyElementEngine;
import pine.core.Disposable;
import pine.Component;
import pine.debug.Debug;
import pine.element.ElementEngine;
import pine.state.*;

function useTrackedProxyEngine<T:Component>(render:(element:ElementOf<T>)->Component):CreateElementEngine {
  return (element:ElementOf<T>) -> {
    var computation:Null<Computation<Component>> = null;
    var requestedUpdate:Bool = false;  
    var factory = useProxyElementEngine(element -> {
      if (computation != null) {
        if (requestedUpdate) {
          computation.revalidate();
          requestedUpdate = false;
        }
        return computation.peek();
      }

      requestedUpdate = true;
      computation = new Computation(() -> {
        var component = render(element);
        switch element.status {
          case Building if (requestedUpdate):
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
      requestedUpdate = false;
      computation.peek();
    });

    element.watchLifecycle({
      beforeUpdate: (_, _, _) -> { 
        requestedUpdate = true;
      },
      beforeDispose: _ -> {
        if (computation != null) {
          computation.dispose();
          computation = null;
        }
      }
    });
    
    return factory(element);
  };
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
