package pine;

import haxe.ds.List;

using Lambda;

@:forward
abstract Process(Array<() -> Void>) {
  static final stack:List<Process> = new List();
  
  public static function current():Process {
    var process = stack.last();
    if (process == null) return start();
    return process;
  }

  public inline static function scope(run:()->Void) {
    start();
    run();
  }

  public inline static function defer(effect) {
    return current().enqueue(effect);
  }

  public static function start() {
    var process = new Process();
    stack.add(process);
    nextFrame(() -> {
      stack.remove(process);
      process.dequeue();
    });
    return process;
  }

  public inline function new(?effects) {
    this = effects != null ? effects : [];
  }

  public function enqueue(effect:() -> Void):()->Void {
    this.push(effect);
    return () -> this.remove(effect);
  }

  public function dequeue() {
    var effect = this.pop();
    while (effect != null) {
      effect();
      effect = this.pop();
    }
  }
}

#if js
private final hasRaf:Bool = js.Syntax.code("typeof window != 'undefined' && 'requestAnimationFrame' in window");
#end

private function nextFrame(exec:() -> Void) {
  #if js
  if (hasRaf) js.Syntax.code('window.requestAnimationFrame({0})', _ -> exec()); else
  #end
  haxe.Timer.delay(() -> exec(), 10);
}
