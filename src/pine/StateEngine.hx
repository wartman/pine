package pine;

@:allow(pine)
class StateEngine {
  static var instance:Null<StateEngine> = null;

  public static function get():StateEngine {
    if (instance == null) instance = new StateEngine();
    return instance;
  }

  var current:Null<Observer>;
  var pending:Array<Observer> = [];
  var depth:Int = 0;

  public function new() {}

  public function validate() {
    if (depth > 0) return;

    var queue = pending.copy();
    var prev = current;
    pending = [];
    for (observer in queue) {
      current = observer;
      observer.validate();
      current = prev;
    }
  }

  public function enqueue(observer:Observer) {
    if (!pending.contains(observer)) pending.push(observer);
  }

  public function batch(compute:()->Void) {
    depth++;
    compute();
    depth--;
    validate();
  }
}
