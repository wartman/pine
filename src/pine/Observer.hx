package pine;

import haxe.Exception;

enum ObserverStatus {
  Inactive;
  Valid;
  Invalid;
  Validating;
}

@:allow(pine)
class Observer implements Disposable {
  final handler:()->Void;
  final dependencies:Array<State<Dynamic>> = [];
  var status:ObserverStatus = Valid;

  public function new(handler) {
    this.handler = handler;

    invalidate();
    Engine.get().validate();
  }

  public function invalidate() {
    switch status {
      case Validating:
        Debug.error('Cycle detected');
      case Invalid | Inactive:
      case Valid:
        status = Invalid;
        Engine.get().enqueue(this);
    }
  }

  public function validate() {
    if (status == Validating) {
      Debug.error('Cycle detected');
    }

    if (status == Inactive || status == Valid) return;

    var err:Null<Exception> = null;
    status = Validating;

    for (signal in dependencies) signal.removeObserver(this);
    try {
      handler();
    } catch (e) {
      err = e;
    }

    status = Valid;
    if (err != null) throw err;
  }

  inline function addDependency(signal:State<Dynamic>) {
    if (!dependencies.contains(signal)) dependencies.push(signal);
  }

  inline function removeDependency(signal:State<Dynamic>) {
    dependencies.remove(signal);
  }

  public function dispose() {
    status = Inactive;
    var toRemove = dependencies.copy();
    for (signal in toRemove) signal.removeObserver(this);
  }
}
