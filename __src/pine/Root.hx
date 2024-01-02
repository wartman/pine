package pine;

import pine.debug.Debug;
import pine.signal.Observer;
import pine.internal.ObjectHost;

class Root extends Component implements ObjectHost {
  final object:Dynamic;
  final build:()->Component;
  var child:Null<Component>;
  
  public function new(object:Dynamic, build, adaptor) {
    this.object = object;
    this.build = build;
    this.adaptor = adaptor;
  }

  public function getObject():Dynamic {
    return object;
  }

  public function visitChildren(visitor:(child:Component) -> Bool) {
    if (child != null) visitor(child);
  }

  public function initialize() {
    Observer.untrack(() -> {
      assert(componentBuildStatus != Building);
      assert(componentLifecycleStatus != Disposed);
      assert(child == null);

      if (componentLifecycleStatus == Disposing) return;

      switch componentLifecycleStatus {
        case Hydrating(cursor):
          componentBuildStatus = Building;
          child = build();
          child.hydrate(this, cursor.currentChildren(), slot ?? createSlot(0, null));
          cursor.next();
        default:
          componentBuildStatus = Building;
          child = build();
          child.mount(this, slot ?? createSlot(0, null));
      }

      componentBuildStatus = Built;
    });
  }

  function initializeObject() {
    // noop
  }

  function disposeObject() {
    // noop
  }
}
