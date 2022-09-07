package pine;

import haxe.Exception;
import pine.internal.Tracking;

enum ObserverStatus {
  Inactive;
  Valid;
  Invalid;
  Validating;
}

@:allow(pine)
class Observer implements Disposable {
  inline public static function track(handler) {
    return new Observer(handler);
  }

  final handler:()->Void;
  final dependencies:Array<State<Dynamic>> = [];
  var status:ObserverStatus = Valid;

  public function new(handler) {
    this.handler = handler;

    invalidate();
    validateObservers();
  }

  function invalidate() {
    switch status {
      case Validating:
        Debug.error('Cycle detected');
      case Invalid | Inactive:
      case Valid:
        status = Invalid;
        enqueueObserver(this);
    }
  }

  function validate() {
    if (status == Validating) {
      Debug.error('Cycle detected');
    }

    if (status == Inactive || status == Valid) return;

    var err:Null<Exception> = null;
    status = Validating;

    for (state in dependencies) state.removeObserver(this);
    try {
      handler();
    } catch (e) {
      err = e;
    }

    status = Valid;
    if (err != null) throw err;
  }

  inline function trackDependency(state:State<Dynamic>) {
    if (!dependencies.contains(state)) dependencies.push(state);
  }

  inline function untrackDependency(state:State<Dynamic>) {
    dependencies.remove(state);
  }

  public function dispose() {
    status = Inactive;
    var toRemove = dependencies.copy();
    for (state in toRemove) state.removeObserver(this);
  }
}
