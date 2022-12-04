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
          .getComponent()
          .asTrackable()
          .sure()
          .initTrackedObject();
      },
    
      beforeUpdate: (element, current, incoming) -> {
        if (current == incoming) return;
        var object = current.asTrackable().sure().getTrackedObject();
        incoming.asTrackable().sure().reuseTrackedObject(object);
      },
    
      onDispose: element -> {
        var object = element
          .getComponent()
          .asTrackable()
          .sure()
          .getTrackedObject();
        if (object != null) object.dispose();
      }
    });
  }
}
