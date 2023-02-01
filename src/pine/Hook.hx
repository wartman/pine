package pine;

import pine.state.Computation;
import pine.core.Disposable;
import pine.debug.Debug;
import pine.state.Observer;
import pine.state.Signal;

private final hookRegistry:Map<Context, Hook<Dynamic>> = [];

typedef HookEntry<T> = { value:T, ?cleanup:(value:T)->Void }; 

class Hook<T:Component> implements Disposable {
  public static function from<T:Component>(element:ElementOf<T>):Hook<T> {
    var hook:Hook<T> = cast hookRegistry.get(element);
    if (hook == null) {
      hook = new Hook(element);
      hookRegistry.set(element, hook);
      return hook;
    }
    return hook;
  }

  final element:ElementOf<T>;
  var index = 0;
  var entries:Array<Null<HookEntry<Dynamic>>> = [];
  #if debug
  var inHook = false;
  var expectedCount = 0;
  #end

  public function new(element) {
    this.element = element;
    
    var events = element.events;

    events.beforeDispose.add(_ -> {
      hookRegistry.remove(element);
      dispose();
    });
    events.beforeInit.add((_, _) -> reset());
    events.beforeUpdate.add((_, _, _) -> reset());
    
    #if debug
    events.afterInit.add((_, _) -> {
      expectedCount = index;
    });
    events.afterUpdate.add((_) -> {
      Debug.assert(
        index == expectedCount, 
        'The current component should use $expectedCount hooks, but'
        + ' $index hooks were used. Make sure hooks are not used inside'
        + ' conditionals (like if statements), loops or function calls.'
        + ' They should only be used at the top of a render method.'
      );
    });
    #end
  }

  /**
    Use a constant value that does not change for this context.
  **/
  public function useMemo<R>(factory:()->R, ?cleanup:(data:R)->Void):R {
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
  public function useSignal<R>(factory:()->R, ?comparator):Signal<R> {
    var index = useIndex();
    var entry:Null<HookEntry<Signal<R>>> = getEntry(index);

    return if (entry == null) {
      var signal = new Signal(runFactory(factory), comparator);
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
    Use a value that is updated any time one of its signals changes.

    Note: think of `useComputed` like a mutable variable, and `useMemo`
    as a constant. This should help you figure out which you should use.
  **/
  public function useComputed<R>(factory:()->R, ?comparator):Computation<R> {
    var factoryIndex = useIndex();
    var index = useIndex();
    var entry:Null<HookEntry<Computation<R>>> = getEntry(index);

    setEntry(factoryIndex, factory);

    return if (entry == null) {
      var computation = new Computation(() -> {
        var entry = getEntry(factoryIndex);
        var currentFactory:()->R = entry == null ? factory : entry.value;
        return runFactory(currentFactory);
      }, comparator);
      setEntry(index, computation, computation -> computation.dispose());
      return computation;
    } else {
      entry.value;
    }
  }

  /**
    Use an observer.

    This is somewhat similar to `useEffect` in React, but it 
    does not work in quite the same way. It updates when its 
    signals change, *not* when its component is re-rendered.
    In addition, it will be run immediately when created.

    The observer expects a cleanup method to be returned, 
    which will be run once when the Element is disposed.

    @todo: A more react-like `useEffect` could be added later.
    The `useNext` hook may be closer to the desired behavior,
    although it will run *every* render. 
  **/
  public function useObserver(effect:()->(()->Void)) {
    var effectIndex = useIndex();
    var index = useIndex();
    var entry:Null<HookEntry<Observer>> = getEntry(index);

    setEntry(effectIndex, effect);

    if (entry == null) {
      var cleanup:Null<()->Void> = null;
      setEntry(index, new Observer(() -> {
        var entry = getEntry(effectIndex);
        var currentEffect:()->(()->Void) = entry == null ? effect : entry.value;
        cleanup = runFactory(currentEffect);
      }), observer -> {
        observer.dispose();
        if (cleanup != null) cleanup();
      });
    }
  }

  /**
    Create a Ref that will persist between renders.

    Use `init` to create the initial render. Note that this will
    be ignored after the first time it is called.
  **/
  public function useRef<T>(?init:()->T):{ current:Null<T> } {
    return useMemo(() -> { 
      current: init == null ? null : init() 
    }, ref -> ref.current = null);
  }

  /**
    Use a callback that has a reference to the current Element. The callback
    will only be run once, meaning that this is primarily intended as a way
    to use an Element's events.
  **/
  public function useElement(handler:(element:ElementOf<T>)->(()->Void)) {
    useMemo(() -> handler(element), cancel -> cancel());
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
    useMemo(() -> cleanup, cleanup -> cleanup());
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
    // @todo: think about if the following line makes sense:
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
