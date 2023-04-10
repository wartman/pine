package pine2;

import kit.Assert;
import pine2.signal.Observer;
import pine2.internal.ObjectHost;

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
    initializeObject();
  }

  function initializeObject() {
    var childrenObserver = new Observer(() -> {
      assert(status != Building);
      assert(status != Disposing);
      assert(status != Disposed);
      if (child != null) child.dispose();
      child = build();
      child?.mount(this, slot ?? createSlot(0, null));
      status = Valid;
    });
    addDisposable(childrenObserver);
  }

  function teardownObject() {
    // noop
  }
}
