package pine.bridge;

#if pine.client
  #error "ServerComponents cannot be used on the client"
#end

import pine.signal.Resource;
import pine.debug.Debug;

using Kit;
using pine.signal.Tools;

// @todo: Probably more to do here, but the basic idea is that 
// ServerComponents can just return a Task<Child>. There's no need
// to show loading states on server-side components, so we can just
// render a placeholder until the component is ready.
@:autoBuild(pine.ComponentBuilder.build())
abstract class ServerComponent extends View {
  var __owner:Owner = new Owner();
  var __child:Null<View> = null;

  abstract function render():Task<Child>;

  function __initialize() {
    assert(get(Suspense) != null, 'ServerComponents must be used inside a Suspense.');

    __child = __owner.own(() -> Resource.suspends(this)
      .fetch(render)
      .scope(result -> switch result {
        case Ok(view):
          view;
        case Error(_) | Loading:
          // @todo: This *should* just get propagated up to the Suspense
          // component. 
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

  function __updateSlot(previousSlot:Null<Slot>, newSlot:Null<Slot>):Void {
    __child?.setSlot(newSlot);
  }

  function __dispose():Void {
    __owner.dispose();
    __child?.dispose();
    __child = null;
  }
}
