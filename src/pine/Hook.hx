package pine;

import pine.core.Disposable;
import pine.debug.Debug;
import pine.state.Observer;
import pine.state.Signal;

private final hookRegistry:Map<Context, Hook<Dynamic>> = [];

typedef HookEntry<T> = { value:T, ?cleanup:(value:T)->Void }; 

class Hook<T:Component> implements Disposable {
  public static function from<T:Component>(element:ElementOf<T>):Hook<T> {
    if (!hookRegistry.exists(element)) {
      var hook = new Hook(element);
      hookRegistry.set(element, hook);
    }
    return cast hookRegistry.get(element);
  }

  final element:ElementOf<T>;
  var index = 0;
  var entries:Array<Null<HookEntry<Dynamic>>> = [];
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
    events.beforeRevalidatedRender.add(() -> reset());
    events.beforeInit.add((_, _) -> reset());
    events.beforeUpdate.add((_, _, _) -> reset());
  }

  /**
    Use a constant value that does not change for this context.
  **/
  public function useData<R>(factory:()->R, ?cleanup:(data:R)->Void):R {
    var index = useIndex();
    var entry:Null<HookEntry<R>> = getEntry(index);

    if (entry == null) {
      var value = runFactory(factory);
      setEntry(index, value, cleanup);
      return value;
    }

    return entry.value;
  }

  /**
    Use a signal scoped to this context.
  **/
  public function useSignal<R>(factory:()->R):Signal<R> {
    var index = useIndex();
    var entry:Null<HookEntry<Signal<R>>> = getEntry(index);

    return if (entry == null) {
      var signal = new Signal(runFactory(factory));
      setEntry(index, signal, signal -> {
        if (signal != null) signal.dispose();
      });
      signal;
    } else {
      var signal = entry.value;
      signal.set(runFactory(factory));
      signal;
    }
  }

  /**
    Use an effect.

    Note that this does not work quite like it does in react: the 
    effect is an Observer that updates when its signals change,
    NOT when its component is re-rendered.

    @todo: Determine if this is the behavior we want.
  **/
  public function useEffect(effect:()->(()->Void)) {
    var index = useIndex();
    var entry:Null<HookEntry<Observer>> = getEntry(index);

    if (entry == null) {
      var cleanup:Null<()->Void> = null;
      setEntry(index, runFactory(() -> new Observer(() -> {
        // @todo: do we want to run this cleanup here?
        if (cleanup != null) cleanup();
        cleanup = effect();
      })), observer -> {
        observer.dispose();
        if (cleanup != null) cleanup();
      });
    }
  }

  /**
    Use a callback that has a reference to the current Element. The callback
    will only be run once.
  **/
  public function useElement(handler:(element:ElementOf<T>)->(()->Void)) {
    useData(() -> handler(element), cancel -> cancel());
  }

  /**
    Use a callback that will be run once, after the Element is 
    initialized.
  **/
  public function useInit(handler:()->Void) {
    useElement(element -> element.events.afterInit.add((_, _) -> handler()));
  }

  /**
    Use a callback that will be run once after the Element is initialized
    *and* after every update.
  **/
  public function useNext(handler:()->Void) {
    useElement(element -> {
      var links = [
        element.events.afterInit.add((_, _) -> handler()),
        element.events.afterUpdate.add((_) -> handler())
      ];
      return () -> for (cancel in links) cancel();
    });
  }

  /**
    Use a callback that will be run once every UPDATE, and NOT on Init.
  **/
  public function useUpdate(handler:()->Void) {
    useElement(element -> element.events.afterUpdate.add((_) -> handler()));
  }

  /**
    Use a cleanup method that will be run when the element is disposed.
  **/
  public function useCleanup(cleanup:()->Void) {
    // note: We can't use the `dispose` events on the Element here 
    // as the Hook will be disposed first. There's no good way around
    // this: we need to the hook to dispose on `Element.beforeDispose` 
    // or we run the risk of an effect running on a disposed Element.
    useData(() -> cleanup, cleanup -> cleanup());
  }

  function useIndex() {
    var i = index++;
    if (entries.length == i) {
      entries[i] = null;
    }
    return i;
  }

  function getEntry<R>(index:Int):Null<HookEntry<R>> {
    return entries[index];
  }

  function setEntry<R>(index:Int, value:R, ?cleanup:(value:R)->Void) {
    var prev = entries[index];
    // @todo: is this what we want:
    if (prev != null && prev.cleanup != null) prev.cleanup(prev.value);
    entries[index] = { value: value, cleanup: cleanup };
  }

  function getElement():ElementOf<T> {
    return element;
  }

  public function dispose() {
    var entriesToCleanup = entries.copy();
    
    entries = [];

    for (entry in entriesToCleanup) {
      if (entry != null && entry.cleanup != null) entry.cleanup(entry.value);
    }
  }

  function reset() {
    if (index == 0) return;
    index = 0;
  }

  inline function runFactory<R>(factory:()->R):R {
    #if debug
    Debug.assert(inHook == false, 'Cannot nest hooks');
    var prevInHook = inHook;
    inHook = true;
    #end
    var value = factory();
    #if debug
    inHook = prevInHook;
    #end
    return value;
  }
}
