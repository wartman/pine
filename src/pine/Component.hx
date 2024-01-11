package pine;

import pine.Disposable;
import pine.debug.Debug;
import pine.signal.Graph;

@:autoBuild(pine.ComponentBuilder.build())
abstract class Component extends View implements DisposableHost {
  final __disposables = new DisposableCollection();
  var __child:Null<View> = null;

  abstract public function render():Child;

  public function addDisposable(disposable:DisposableItem):Void {
    __disposables.addDisposable(disposable);
  }

  public function removeDisposable(disposable:DisposableItem):Void {
    __disposables.removeDisposable(disposable);
  }
  
  function __initialize() {
    __child = withOwnedValue(__disposables, () -> untrackValue(render));
    __child.mount(this, getAdaptor(), slot);
  }

  public function findNearestPrimitive():Dynamic {
    return ensureParent().findNearestPrimitive();
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
    __disposables.dispose();
    __child?.dispose();
    __child = null;
  }
}
