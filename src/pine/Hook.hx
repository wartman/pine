package pine;

import pine.core.UniqueId;
import pine.debug.Debug;
import pine.core.Disposable;
import pine.state.Observer;

private final hookRegistry:Map<Context, Hook<Dynamic>> = [];

typedef HookHandler<T:Component> = (element:ElementOf<T>)->Void;

// @todo: Instead of having a hookRegistry, we might just have a
// hook instance on our Element. On the other hand, I think this works fine
// and will only get used if needed.
class Hook<T:Component> implements Disposable {
  public static function from<T:Component>(element:ElementOf<T>):Hook<T> {
    if (!hookRegistry.exists(element)) {
      var hook = new Hook(element);
      hookRegistry.set(element, hook);
    }
    return cast hookRegistry.get(element);
  }

  final element:ElementOf<T>;
  var states:Array<Null<Dynamic>> = [];
  var cleanups:Array<Null<(value:Null<Dynamic>)->Void>> = [];
  var index = 0;
  #if debug
  var inHook = false;
  #end

  public function new(element) {
    this.element = element;
    
    var events = element.events;

    events.beforeDispose.add(_ -> {
      hookRegistry.remove(element);
      dispose();
    });
    events.beforeRevalidatedRender.add(() -> index = 0);
    events.beforeInit.add((element, _) -> reset(null, null));
    events.beforeUpdate.add((element, currentComponent, incomingComponent) -> reset(currentComponent, incomingComponent));
  }
  
  public function useState<R>(
    factory:()->R,
    ?cleanup:(data:R)->Void
  ):R {
    var index = useIndex();
    var data:Null<R> = getState(index);
    
    Debug.assert(inHook == false, 'Cannot nest hooks');

    // @todo: Find a way to throw an error if the user tries to use
    // this hook outside of the top of the render method.

    if (data == null) {
      #if debug
      var prevInHook = inHook;
      inHook = true;
      #end
      data = factory();
      #if debug
      inHook = prevInHook;
      #end
      setState(index, data, cleanup);
    }

    return data;
  }

  public inline function useCleanup(cleanup:()->Void) {
    useState(() -> index, _ -> cleanup());
  }

  public function useEffect(effect:()->Void) {
    Observer.untrack(() -> useState(
      () -> new Observer(effect),
      observer -> observer.dispose()
    ));
  }

  public inline function useElement(handler:(element:ElementOf<T>)->(()->Void)) {
    useState(() -> handler(element), cancel -> cancel());
  }

  public inline function useInit(handler:()->Void) {
    useElement(element -> element.events.afterInit.add((_, _) -> handler()));
  }

  public function useNext(handler:()->Void) {
    useElement(element -> {
      var events = element.events;
      var links = [
        events.afterUpdate.add((_) -> handler()),
        events.afterInit.add((_, _) -> handler())
      ];
      return () -> for (cancel in links) cancel();
    });
  }

  function useIndex() {
    var i = index++;
    if (states.length == i) {
      states[i] = null;
      cleanups[i] = null;
    }
    return i;
  }

  function getState(index:Int):Null<Dynamic> {
    return states[index];
  }

  function setState<R>(index:Int, data:R, ?cleanup:(value:R)->Void) {
    states[index] = data;
    cleanups[index] = cleanup;
  }

  function getElement():ElementOf<T> {
    return element;
  }

	public function dispose() {
    cleanupState();
  }

  function reset(currentComponent:Null<T>, incomingComponent:Null<T>) {
    if (index == 0) return;

    index = 0;
    // @todo: This shouldn't always happen! We should be able to configure this.
    if (currentComponent != null && currentComponent != incomingComponent) {
      cleanupState();
    }
  }

  function cleanupState() {
    var cleanupMethods = cleanups.copy();
    var cleanupState = states.copy();
    
    states = [];
    cleanups = [];

    for (index => state in cleanupState) {
      var cleanup = cleanupMethods[index];
      if (cleanup != null) cleanup(state);
    }
  }
}
