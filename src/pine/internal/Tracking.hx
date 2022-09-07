package pine.internal;

var currentObserver:Null<Observer>;

private var pending:Array<Observer> = [];
private var depth:Int = 0;

function validateObservers() {
  if (depth > 0) return;

  var queue = pending.copy();
  var prev = currentObserver;
  pending = [];
  for (observer in queue) {
    currentObserver = observer;
    observer.validate();
    currentObserver = prev;
  }
}

function enqueueObserver(observer:Observer) {
  if (!pending.contains(observer)) pending.push(observer);
}

function batchInvalidateStates(compute:()->Void) {
  depth++;
  compute();
  depth--;
  validateObservers();
}
