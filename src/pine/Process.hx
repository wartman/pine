package pine;

abstract class Process {
  public inline static function from(context:Context) {
    return Adapter.from(context).getProcess();
  }

  final effects:Array<() -> Void> = [];
  var isStarted:Bool = false;
  
  public function new() {}
  
  function enqueue(effect:() -> Void):()->Void {
    effects.push(effect);
    return () -> effects.remove(effect);
  }

  public function defer(effect:() -> Void) {
    var cancel = enqueue(effect);
    if (!isStarted) {
      isStarted = true;
      nextFrame(() -> {
        isStarted = false;
        var fx = effects.copy();
        effects.resize(0);
        for (effect in fx) effect();
      });
    }
    return cancel;
  }

  abstract function nextFrame(exec:()->Void):Void;
}
