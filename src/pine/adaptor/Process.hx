package pine.adaptor;

import haxe.ds.Option;

using pine.core.OptionTools;

abstract class Process {
  public static function from(context:Context):Process {
    return maybeFrom(context).orThrow('No Process found');
  }

  public static function maybeFrom(context:Context):Option<Process> {
    return switch Adaptor.maybeFrom(context) {
      case Some(adaptor): Some(adaptor.getProcess());
      case None: None;
    }
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
