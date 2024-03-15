package pine;

import pine.signal.Runtime;
import pine.Disposable;
import pine.debug.Debug;

abstract class ProxyView extends View implements DisposableHost {
  final __owner = new Owner();
  var __child:Null<View> = null;

  abstract function render():Child;

  public function addDisposable(disposable:DisposableItem):Void {
    __owner.addDisposable(disposable);
  }

  public function removeDisposable(disposable:DisposableItem):Void {
    __owner.removeDisposable(disposable);
  }
  
  function __initialize() {
    __child = __owner.own(() -> Runtime.current().untrack(render));
    __child.mount(this, getAdaptor(), slot);
  }

  public function findNearestPrimitive():Dynamic {
    return getParent().findNearestPrimitive();
  }

  public function getPrimitive():Dynamic {
    var primitive = __child?.getPrimitive();
    assert(primitive != null);
    return primitive;
  }

  function __updateSlot(previousSlot:Null<Slot>, newSlot:Null<Slot>):Void {
    __child?.setSlot(newSlot);
  }

  function __dispose():Void {
    __owner.dispose();
    __child?.dispose();
    __child = null;
  }
}
