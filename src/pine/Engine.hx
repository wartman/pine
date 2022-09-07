package pine;

@:allow(pine)
class Engine {
  static var instance:Null<Engine> = null;

  public static function get():Engine {
    if (instance == null) instance = new Engine();
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
