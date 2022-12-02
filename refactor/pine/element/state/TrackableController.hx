package pine.element.state;

using pine.core.OptionTools;

// @todo: The TrackableController is persistant, so we
// *could* just have the controller control the TrackedObject?
// Not sure how we'd set things up for the Component to have 
// access to it, but it's a thought.
class TrackableController implements Controller<AutoComponent> {
  public function new() {}

  public function register(element:ElementOf<AutoComponent>) {
    element.addHook({
      beforeInit: element -> {
        var comp:AutoComponent = element.getComponent();
        comp.asTrackable().sure().initTrackedObject();
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

  public function dispose() {}
}
