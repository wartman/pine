package pine.element.state;

using pine.core.OptionTools;

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
