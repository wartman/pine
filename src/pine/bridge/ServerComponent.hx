package pine.bridge;

#if pine.client
  #error "ServerComponents cannot be used on the client"
#end

import pine.Disposable;
import pine.signal.Resource;
import pine.debug.Debug;

using Kit;
using pine.signal.Tools;

// @todo: Probably more to do here, but the basic idea is that 
// ServerComponents can just return a Task<Child>. There's no need
// to show loading states on server-side components, so we can just
// render a placeholder until the component is ready.
// @todo: Try to figure out a way to DRY this code up a bit.
@:autoBuild(pine.ComponentBuilder.build())
abstract class ServerComponent extends View implements DisposableHost {
  var __owner:Owner = new Owner();
  var __child:Null<View> = null;

  abstract function render():Task<Child>;

  function __initialize() {
    assert(getContext(Suspense) != null, 'ServerComponents must be used inside a Suspense.');

    __child = __owner.own(() -> Resource.suspends(this)
      .fetch(render)
      .scope(result -> switch result {
        case Ok(view):
          view;
        case Error(_) | Loading:
          // @todo: Consider what we should do about the Error
          // case. It *should* get pushed up to the Suspense
          // component and handled by the generator, so it *should*
          // be fine.
          Placeholder.build();
      })
    );
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

  public function addDisposable(disposable:DisposableItem):Void {
    __owner.addDisposable(disposable);
  }

  public function removeDisposable(disposable:DisposableItem):Void {
    __owner.removeDisposable(disposable);
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
