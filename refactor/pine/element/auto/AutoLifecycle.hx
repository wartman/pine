package pine.element.auto;

using pine.core.OptionTools;

/**
  Lifecycle hooks to ensure tracked objects are resused as
  much as possible inside components.

  Note: This is mostly intended as an internal implementation
  detail. Use at your own risk.
**/
final lifecycle:LifecycleHooks<AutoComponent> = {
  beforeInit: (element:ElementOf<AutoComponent>) -> {
    var comp:AutoComponent = element.getComponent();
    comp.asTrackable().sure().initTrackedObject();
  },

  beforeUpdate: (
    element:ElementOf<AutoComponent>,
    currentComponent:AutoComponent,
    incomingComponent:AutoComponent
  ) -> {
    if (currentComponent == incomingComponent) return;
    var object = currentComponent.asTrackable().sure().getTrackedObject();
    incomingComponent.asTrackable().sure().reuseTrackedObject(object);
  },

  onDispose: (element:ElementOf<AutoComponent>) -> {
    var comp:AutoComponent = element.getComponent();
    var object = comp.asTrackable().sure().getTrackedObject();
    if (object != null) object.dispose();
  }
}
