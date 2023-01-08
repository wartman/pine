package pine.html.client;

import pine.adaptor.Process;

private final hasRaf:Bool = js.Syntax.code("typeof window != 'undefined' && 'requestAnimationFrame' in window");

class ClientProcess extends Process {
  function nextFrame(exec:() -> Void) {
    if (hasRaf) 
      js.Syntax.code('window.requestAnimationFrame({0})', _ -> exec()); 
    else
      haxe.Timer.delay(() -> exec(), 10);
  }
}
