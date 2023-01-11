package pine;

import haxe.ds.Option;
import pine.debug.Debug;
import pine.element.ElementEngine;
import pine.element.ProxyElementEngine;
import pine.state.*;

using pine.core.OptionTools;

@:allow(pine)
@:autoBuild(pine.AutoComponentBuilder.build())
@:autoBuild(pine.core.HasComponentTypeBuilder.build())
abstract class AutoComponent extends Component {
  abstract public function render(context:Context):Component;

  @:noCompletion
  abstract function getTrackedObjectManager():Option<TrackedObjectManager<Dynamic>>;
}

function useTrackedElementEngine<T:Component>(render:(element:ElementOf<T>)->Component):CreateElementEngine {
  return (element:ElementOf<T>) -> {
    var computation:Null<Computation<Component>> = null;
    var isUpdating:Bool = false;
    new ProxyElementEngine<T>(
      element,
      element -> {
        if (computation != null) return computation.peek();

        element.events.beforeUpdate.add((_, _, _) -> {
          isUpdating = true;
          if (computation != null) computation.revalidate();
        });
        element.events.afterUpdate.add((_) -> {
          isUpdating = false;
        });
        element.events.beforeDispose.add((_) -> {
          if (computation != null) {
            computation.dispose();
            computation = null;
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
      }
    );
  }
}

typedef TrackedObjectManager<T> = {
  public function initTrackedObject():T;
  public function getTrackedObject():T;
  public function reuseTrackedObject(trackedObject:T):T;
}

function syncTrackedObject():Hook<AutoComponent> {
  return (element:ElementOf<AutoComponent>) -> {
    element.watchLifecycle({
      beforeInit: (element, mode) -> {
        element
          .component
          .getTrackedObjectManager()
          .orThrow('Component is not trackable')
          .initTrackedObject();
      },
    
      beforeUpdate: (element, current, incoming) -> {
        if (current == incoming) return;
        var object = locateTrackedObject(current)
          .orThrow('No tracked object found');

        incoming
          .getTrackedObjectManager()
          .orThrow('Incoming component is not trackable')
          .reuseTrackedObject(object);
      },
    
      beforeDispose: element -> {
        locateTrackedObject(element.component)
          .some(object -> object.dispose());
      }
    });
  }
}

inline function locateTrackedObject(comp:AutoComponent) {
  return comp.getTrackedObjectManager().map(trackable -> {
    var object = trackable.getTrackedObject();
    if (object == null) return None; 
    Some(object);
  });
}
