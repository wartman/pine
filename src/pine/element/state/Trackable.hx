package pine.element.state;

using pine.core.OptionTools;

typedef Trackable<T> = {
  public function initTrackedObject():T;
  public function getTrackedObject():T;
  public function reuseTrackedObject(trackedObject:T):T;
}

function syncTrackedObject():Hook<AutoComponent> {
  return (element:ElementOf<AutoComponent>) -> {
    element.watchLifecycle({
      beforeInit: element -> {
        element
          .component
          .asTrackable()
          .orThrow('Component is not trackable')
          .initTrackedObject();
      },
    
      beforeUpdate: (element, current, incoming) -> {
        if (current == incoming) return;
        var object = locateTrackedObject(current)
          .orThrow('No tracked object found');

        incoming
          .asTrackable()
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
  return comp.asTrackable().map(trackable -> {
    var object = trackable.getTrackedObject();
    if (object == null) return None; 
    Some(object);
  });
}
