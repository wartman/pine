package pine.html.dom;

private final hasRaf:Bool = js.Syntax.code("typeof window != 'undefined' && 'requestAnimationFrame' in window");

class DomProcess extends Process {
  function nextFrame(exec:() -> Void) {
    if (hasRaf) 
      js.Syntax.code('window.requestAnimationFrame({0})', _ -> exec()); 
    else
      haxe.Timer.delay(() -> exec(), 10);
  }
}
