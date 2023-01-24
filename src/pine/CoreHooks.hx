package pine;

import pine.state.Observer;

function useState<T:Component, R>(
  hook:Hook<T>,
  factory:()->R,
  ?cleanup:(data:R)->Void
):R {
  var index = hook.useIndex();
  var data:Null<R> = hook.getState(index);
  
  // @todo: Find a way to throw an error if the user tries to use
  // this hook outside of the top of the render method.

  if (data == null) {
    data = factory();
    hook.setState(index, data, cleanup);
  }

  return data;
}

function useEffect<T:Component>(hook:Hook<T>, effect:()->Void) {
  Observer.untrack(() -> useState(
    hook,
    () -> new Observer(effect),
    observer -> observer.dispose()
  ));
}

function useElement<T:Component>(hook:Hook<T>, handler:(element:ElementOf<T>)->(()->Void)) {
  useState(hook, () -> {
    var element = hook.getElement();
    return handler(element);
  }, cancel -> cancel());
}

function useInit<T:Component>(hook:Hook<T>, handler:()->Void) {
  useElement(hook, element -> element.events.afterInit.add((_, _) -> handler()));
}

function useNext<T:Component>(hook:Hook<T>, handler:()->Void) {
  useElement(hook, element -> {
    var events = element.events;
    var links = [
      events.afterUpdate.add((_) -> handler()),
      events.afterInit.add((_, _) -> handler())
    ];
    return () -> for (cancel in links) cancel();
  });
}
