package medic;

import haxe.PosInfos;
import impl.*;
import pine.*;

inline function mount(component:Component, ?handler:(result:TestingObject) -> Void) {
  var boot = new TestingBootstrap();
  var root = boot.mount(component);
  if (handler != null) handler(root.getObject());
  return root;
}

function renders(widget:Component, expected:String, next:() -> Void, ?p:PosInfos) {
  mount(widget, actual -> {
    Assert.equals(actual.toString(), expected, p);
    next();
  });
}

function renderWithoutAssert(component:Component) {
  var boot = new TestingBootstrap();
  boot.mount(component);
}

function asTracked(handler:(next:()->Void)->Void, next:()->Void) {
  var deffered = () -> Process.defer(next);
  return new Observer(() -> {
    // Note: This ensures that we don't trigger the next test while still
    // inside the current Observer.
    handler(deffered);
  });
}
