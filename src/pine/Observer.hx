package pine;

import haxe.Exception;
import haxe.ds.List;

using Lambda;

@:allow(pine)
class Observer implements Disposable {
  static final stack:List<Null<Observer>> = new List();

  final signals:List<Signal<Dynamic>> = new List();
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
      clearDependencies();

      if (isUntracked) {
        stack.push(null);
      } else {
        stack.push(this);
      }
      try
        handler()
      catch (e)
        err = e;

      stack.pop();
      isTriggering = false;

      if (err != null) throw err;
    }
  }

  public function stop() {
    isRunning = false;
    clearDependencies();
  }

  public function start() {
    if (!isRunning) {
      isRunning = true;
      trigger();
    }
  }

  function clearDependencies() {
    for (signal in signals) signal.observers.remove(this);
    signals.clear();
  }

  public function dispose() {
    stop();
  }
}
