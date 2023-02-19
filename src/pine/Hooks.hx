package pine;

import pine.hook.SignalHook.SignalHookState;
import pine.hook.MemoHook.MemoHookState;
import pine.hook.*;

function useMemo<T>(context:Context, createValue, ?cleanup) {
  var state:MemoHookState<T> = HookContext
    .from(context)
    .use(new MemoHook<T>({ create: createValue, cleanup: cleanup }));
  return state.getValue();
}

function useRef<T>(context:Context):{ current:Null<T> } {
  return useMemo(context, () -> { current: null }, ref -> ref.current = null);
}

function useSignal<T>(context:Context, createValue) {
  var signal:SignalHookState<T> = HookContext
    .from(context)
    .use(new SignalHook<T>(createValue));
  return signal.getSignal();
}

function useObserver(context:Context, handler) {
  HookContext.from(context).use(new ObserverHook(handler));
}

function useEffect(context:Context, handler:()->Null<()->Void>) {
  HookContext.from(context).use(new EffectHook(handler));
}

function useCleanup(context:Context, cleanup:()->Void) {
  useMemo(context, () -> cleanup, cleanup -> cleanup());
}

function useElement<T:Component>(element:ElementOf<T>, handler:(element:ElementOf<T>)->Null<()->Void>) {
  useMemo(element, () -> handler(element), cleanup -> if (cleanup != null) cleanup());
}

function useInit(context:Context, handler:()->Null<()->Void>) {
  useElement(context, element -> {
    var cleanup:Null<()->Void> = null;
    var cancel = element.events.afterInit.add((_, _) -> cleanup = handler());
    return () -> {
      cancel();
      if (cleanup != null) {
        cleanup();
        cleanup = null;
      }
    }
  });
}

function useUpdate(context:Context, handler:()->Null<()->Void>) {
  useElement(context, element -> {
    var cleanup:Null<()->Void> = null;
    var cancel = element.events.afterUpdate.add((_) -> {
      if (cleanup != null) cleanup();
      cleanup = handler();
    });
    return () -> {
      cancel();
      if (cleanup != null) {
        cleanup();
        cleanup = null;
      }
    }
  });
}

function useNext(context:Context, handler:()->Null<()->Void>) {
  useElement(context, element -> {
    var cleanup:Null<()->Void> = null;
    var run = () -> {
      if (cleanup != null) cleanup();
      cleanup = handler();
    }
    var links = [
      element.events.afterInit.add((_, _) -> run()),
      element.events.afterUpdate.add((_) -> run())
    ];
    return () -> {
      for (cancel in links) cancel();
      if (cleanup != null) {
        cleanup();
        cleanup = null;
      }
    }
  });
}
