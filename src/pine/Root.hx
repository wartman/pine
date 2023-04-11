package pine;

import kit.Assert;
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
      assert(status != Building);
      assert(status != Disposed);
      assert(child == null);

      if (status == Disposing) return;

      switch status {
        case Initializing(Hydrating(cursor)):
          status = Building;
          child = build();
          child.hydrate(this, cursor.currentChildren(), slot ?? createSlot(0, null));
          cursor.next();
        default:
          status = Building;
          child = build();
          child.mount(this, slot ?? createSlot(0, null));
      }

      status = Built;
    });
  }

  function initializeObject() {
    // noop
  }

  function teardownObject() {
    // noop
  }
}
