package pine;

import pine.state.Observer;

/**
  Create an Observer that will be automatically disposed when
  its Element is.
  
  Note: This is named similarly to React's `useEffect` as it provides
  similar functionality. Note that it WILL NOT update for every render.
  It only changes when an observed Signal does.
**/
function createEffect<T:Component>(handle:(element:ElementOf<T>)->Void):Hook<T> {
  return beforeInit(element -> {
    var observer = new Observer(() -> handle(element));
    element.addDisposable(observer);
  });
}

/**
  A hook that will run *before* an Element has been initialized.

  Note that this will also fire during hydration.
**/
function beforeInit<T:Component>(handler):Hook<T> {
  return element -> element.watchLifecycle({
    beforeInit: (element, _) -> handler(element)
  });
}

/**
  A hook that will run *after* an Element has been successfully
  initialized.

  Note that this will also fire during hydration.
**/
function afterInit<T:Component>(handler):Hook<T> {
  return element -> element.watchLifecycle({
    afterInit: (element, _) -> handler(element)
  });
}

/**
  A hook that will run *before* an Element is initialized and *before*
  it is updated.
**/
function beforeChange<T:Component>(handler:(element:ElementOf<T>)->Void):Hook<T> {
  return element -> element.watchLifecycle({
    beforeInit: (element, _) -> handler(element),
    beforeUpdate: (element, _, _) -> handler(element) 
  });
}

/**
  A hook that *only* runs when the Element is updated. This means that
  this hook will *not* run on initialization: use `beforeChange` for that
  behavior. 
**/
function beforeUpdate<T:Component>(handler):Hook<T> {
  return element -> element.watchLifecycle({
    beforeUpdate: handler
  });
}
