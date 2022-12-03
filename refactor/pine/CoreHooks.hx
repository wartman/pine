package pine;

import pine.state.Observer;

function createEffect<T:Component>(handle:(element:ElementOf<T>)->Void):Hook<T> {
  return element -> element.onReady(_ -> {
    var observer = new Observer(() -> handle(element));
    element.addDisposable(observer);
  });
}
