package pine.html.server;

class ServerProcess extends Process {
  function nextFrame(exec:() -> Void) {
    haxe.Timer.delay(() -> exec(), 10);
  }
}
