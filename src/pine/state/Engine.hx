package pine.state;

using Lambda;

var currentObserver:Null<Observer> = null;
private final pending:List<Observer> = new List();
private var depth:Int = 0;

function validateObservers() {
  if (depth > 0) return;
  
  for (observer in pending) {
    var prev = currentObserver;

    pending.remove(observer);
    currentObserver = observer;
    observer.validate();
    currentObserver = prev;
  }
}

function enqueueObserver(observer:Observer) {
  if (!pending.has(observer)) pending.add(observer);
}

function untrack(compute:()->Void) {
  var prev = currentObserver;
  currentObserver = null;
  compute();
  currentObserver = prev;
}

function batch(compute:()->Void) {
  depth++;
  compute();
  depth--;
  validateObservers();
}

function bind(observer:Observer, state:Signal<Dynamic>) {
  if (!state.observers.has(observer)) {
    observer.dependencies.add(state);
    state.observers.add(observer);
  }
}

function unbind(observer:Observer, state:Signal<Dynamic>) {
  observer.dependencies.remove(state);
  state.observers.remove(observer);
}
