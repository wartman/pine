package pine;

import haxe.Exception;
import haxe.ds.List;

using Lambda;

@:allow(pine)
class Observer implements Disposable {
  static final stack:List<Null<Observer>> = new List();
  static var currentQueue:Null<ObserverQueue> = null;

  static function scheduleTrigger(observers:List<Observer>) {
    if (currentQueue != null) {
      for (observer in observers) currentQueue.enqueue(observer);
      return;
    }

    var queue = currentQueue = new ObserverQueue();
    for (observer in observers) currentQueue.enqueue(observer);

    Process.defer(() -> {
      currentQueue = null;
      queue.dequeue();
    });
  }

  final states:List<State<Dynamic>> = new List();
  final handler:() -> Void;
  var isTriggering:Bool = false;
  var isActive:Bool = false;
  var isUntracked:Bool = false;

  public function new(handler, untracked = false) {
    this.handler = handler;
    this.isUntracked = untracked;
    start();
  }

  public function trigger() {
    if (isTriggering) {
      Debug.error('Observer was triggered while already running');
    }

    if (isActive) {
      var err:Null<Exception> = null;

      isTriggering = true;
      clearTrackedStates();

      if (isUntracked) {
        stack.push(null);
      } else {
        stack.push(this);
      }

      try {
        handler();
      } catch (e) {
        err = e;
      }

      stack.pop();
      isTriggering = false;

      if (err != null) throw err;
    }
  }

  public function stop() {
    isActive = false;
    clearTrackedStates();
  }

  public function start() {
    if (!isActive) {
      isActive = true;
      trigger();
    }
  }

  public function track(state:State<Dynamic>) {
    if (!state.observers.has(this)) {
      state.observers.add(this);
      states.add(state);
    }
  }

  function clearTrackedStates() {
    for (state in states) state.observers.remove(this);
    states.clear();
  }

  public function dispose() {
    stop();
  }
}

private abstract ObserverQueue(Array<Observer>) {
  public inline function new() {
    this = [];
  }

  public inline function enqueue(observer:Observer) {
    if (!this.contains(observer)) {
      this.push(observer);
    }
  }

  public inline function dequeue() {
    var observer = this.pop();
    while (observer != null) {
      observer.trigger();
      observer = this.pop();
    }
  }
}
