package pine.adaptor;

using Kit;

// @todo: Replace this with a more robust scheduler?
abstract class Process {
  public static function from(context:Context):Process {
    return maybeFrom(context).orThrow('No process found');
  }

  public static function maybeFrom(context:Context):Maybe<Process> {
    return Adaptor.maybeFrom(context).map(adaptor -> Some(adaptor.getProcess()));
  }

  final effects:List<() -> Void> = new List();
  var isStarted:Bool = false;
  
  public function new() {}
  
  function enqueue(effect:() -> Void):()->Void {
    effects.add(effect);
    return () -> effects.remove(effect);
  }

  public function defer(effect:() -> Void) {
    var cancel = enqueue(effect);
    if (!isStarted) {
      isStarted = true;
      nextFrame(() -> {
        var effect = effects.first();
        while (effect != null) {
          effects.remove(effect);
          effect();
          effect = effects.first();
        }
        isStarted = false;
      });
    }
    return cancel;
  }

  abstract function nextFrame(exec:()->Void):Void;
}
