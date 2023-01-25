package pine.element;

import pine.Component;
import pine.core.Disposable;
import pine.debug.Debug;
import pine.element.ElementEngine;
import pine.element.ProxyElementEngine.useProxyElementEngine;
import pine.state.*;

function useTrackedProxyEngine<T:Component>(render:(element:ElementOf<T>)->Component):CreateElementEngine {
  return (element:ElementOf<T>) -> {
    var computation:Null<Computation<Component>> = null;
    var wasCalledByElement:Bool = false;  
    var factory = useProxyElementEngine(element -> {
      Debug.assert(element.status == Building);
      wasCalledByElement = true;

      if (computation != null) {
        computation.revalidate();
        wasCalledByElement = false;
        return computation.peek();
      }
      
      // @todo: This current implementation will call `render` more than
      // once if the component is invalidated.
      computation = new Computation(() -> {
        if (!wasCalledByElement) {
          // @todo: This is a bit hacky, but we need it to make sure
          // our Hook is resetting its index
          element.events.beforeRevalidatedRender.dispatch();
        }

        var component = render(element);

        switch element.status {
          case Building if (wasCalledByElement):
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

      wasCalledByElement = false;
      computation.peek();
    });

    element.events.beforeDispose.add(_ -> {
      if (computation != null) {
        computation.dispose();
        computation = null;
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

    element.events.beforeInit.add((element, _) -> {
      Debug.assert(tracked == null);
      tracked = options.init(element.component);
    });
    element.events.beforeUpdate.add((element, currentComponent, incomingComponent) -> {
      if (currentComponent == incomingComponent) return;
      Debug.assert(tracked != null);
      options.bind(incomingComponent, tracked);
    });
    element.events.beforeDispose.add(_ -> {
      if (tracked != null) {
        tracked.dispose();
        tracked = null;
      }
    });

    factory(element);
  }
}