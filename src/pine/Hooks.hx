package pine;

import pine.hook.*;

function useMemo<T>(context:Context, createValue, ?cleanup) {
  return HookContext
    .from(context)
    .use(createValue, createValue -> new MemoHook<T>(createValue, cleanup))
    .getValue();
}

function useRef<T>(context:Context):{ current:Null<T> } {
  return useMemo(context, () -> { current: null }, ref -> ref.current = null);
}

function useSignal<T>(context:Context, createValue) {
  return HookContext
    .from(context)
    .use(createValue, createValue -> new SignalHook<T>(createValue))
    .getSignal();
}

function useObserver(context:Context, handler) {
  HookContext.from(context).use(handler, handler -> new ObserverHook(handler));
}

function useEffect(context:Context, handler:()->Null<()->Void>) {
  HookContext.from(context).use(handler, handler -> new EffectHook(context, handler));
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
