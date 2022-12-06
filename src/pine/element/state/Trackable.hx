package pine.element.state;

using pine.core.OptionTools;

typedef Trackable<T> = {
  public function initTrackedObject():T;
  public function getTrackedObject():T;
  public function reuseTrackedObject(trackedObject:T):T;
}

function useSyncTrackedObject():Hook<AutoComponent> {
  return (element:ElementOf<AutoComponent>) -> {
    element.watchLifecycle({
      beforeInit: element -> {
        element
          .component
          .asTrackable()
          .sure()
          .initTrackedObject();
      },
    
      beforeUpdate: (element, current, incoming) -> {
        if (current == incoming) return;
        locateTrackedObject(current)
          .map(object -> incoming
            .asTrackable()
            .map(trackable -> {
              trackable.reuseTrackedObject(object);
              Some(object);
            })
          )
          .orThrow('No tracked object found');
      },
    
      onDispose: element -> {
        locateTrackedObject(element.component).some(object -> object.dispose());
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
