package pine;

// @todo: Perhaps we should get a bit more ambitious with this scheduler?
// Look into what React and Solid are doing and make things use more
// than one thread?
class Scheduler {
  static var instance:Null<Scheduler>;

  public static function getInstance():Scheduler {
    if (instance == null) {
      instance = new Scheduler();
    }
    return instance;
  }

  #if js
  static final hasRaf:Bool = js.Syntax.code("typeof window != 'undefined' && 'requestAnimationFrame' in window");
  #end

  var onUpdate:Null<Array<() -> Void>> = null;

  public function new() {}

  public function schedule(item) {
    if (onUpdate == null) {
      onUpdate = [];
      onUpdate.push(item);
      later(doUpdate);
    } else {
      onUpdate.push(item);
    }
  }

  function later(exec:() -> Void) {
    #if js
    if (hasRaf) js.Syntax.code('window.requestAnimationFrame({0})', _ -> exec()); else
    #end
    haxe.Timer.delay(() -> exec(), 10);
  }

  function doUpdate() {
    if (onUpdate == null) return;

    var currentUpdates = onUpdate.copy();
    onUpdate = null;

    for (item in currentUpdates) item();
  }
}
