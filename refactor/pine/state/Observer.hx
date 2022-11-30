package pine.state;

import haxe.Exception;
import pine.core.Disposable;
import pine.debug.Debug;
import pine.state.Engine;

using Lambda;

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
  final dependencies:List<State<Dynamic>> = new List();
  var status:ObserverStatus = Inactive;

  public function new(handler) {
    this.handler = handler;
    activate();
  }

  public function activate() {
    if (status != Inactive) {
      Debug.error('Attempted to activate an Observer that was already active');
    }

    status = Invalid;

    enqueueObserver(this);
    validateObservers();
  }

  public function validate() {
    if (status == Validating) {
      Debug.error('Cycle detected');
    }

    if (status == Inactive || status == Valid) return;

    var err:Null<Exception> = null;
    status = Validating;

    unbindAllDependencies();
    
    try {
      handler();
    } catch (e) {
      err = e;
    }

    status = Valid;
    if (err != null) throw err;
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

  public function dispose() {
    status = Inactive;
    unbindAllDependencies();
  }

  inline function unbindAllDependencies() {
    for (state in dependencies) unbind(this, state);
  }
}
