package pine;

import haxe.Exception;
import haxe.ds.List;

using Lambda;

@:allow(pine)
class Observer implements Disposable {
  static final stack:List<Null<Observer>> = new List();
  static var currentTask:Null<Task> = null;

  static function scheduleTrigger(observers:List<Observer>) {
    if (currentTask != null) {
      for (observer in observers) currentTask.enqueue(observer);
      return;
    }

    var task = currentTask = new Task();
    for (observer in observers) currentTask.enqueue(observer);
    
    // @todo: Is there a better way to schedule things?
    // We should always be using the same Scheduler across an app.
    Scheduler.getInstance().schedule(() -> {
      currentTask = null;
      task.dequeue();
    });
  }

  final states:List<State<Dynamic>> = new List();
  final handler:() -> Void;
  var isTriggering:Bool = false;
  var isRunning:Bool = false;
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

    if (isRunning) {
      var err:Null<Exception> = null;

      isTriggering = true;
      clearTrackedSignals();

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
    isRunning = false;
    clearTrackedSignals();
  }

  public function start() {
    if (!isRunning) {
      isRunning = true;
      trigger();
    }
  }

  public function track(state:State<Dynamic>) {
    if (!state.observers.has(this)) {
      state.observers.add(this);
      states.add(state);
    }
  }

  function clearTrackedSignals() {
    for (state in states) state.observers.remove(this);
    states.clear();
  }

  public function dispose() {
    stop();
  }
}

private abstract Task(Array<Observer>) {
  public inline function new() {
    this = [];
  }

  public inline function enqueue(observer:Observer) {
    if (!this.contains(observer)) this.push(observer);
  }

  public inline function dequeue() {
    var observer = this.pop();
    while (observer != null) {
      observer.trigger();
      observer = this.pop();
    }
  }
}
