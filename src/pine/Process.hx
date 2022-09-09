package pine;

abstract class Process {
  public inline static function from(context:Context) {
    return context.getRoot().getAdapter().getProcess();
  }

  final effects:Array<() -> Void> = [];
  var isStarted:Bool = false;
  
  public function new() {}
  
  function enqueue(effect:() -> Void):()->Void {
    effects.push(effect);
    return () -> effects.remove(effect);
  }

  function dequeue() {
    var effect = effects.pop();
    while (effect != null) {
      effect();
      effect = effects.pop();
    }
  }

  public function defer(effect:() -> Void) {
    var cancel = enqueue(effect);
    if (!isStarted) {
      isStarted = true;
      nextFrame(() -> {
        dequeue();
        isStarted = false;
      });
    }
    return cancel;
  }

  abstract function nextFrame(exec:()->Void):Void;
}
