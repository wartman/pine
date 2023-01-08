package pine.html.server;

import pine.adaptor.Process;

class ServerProcess extends Process {
  function nextFrame(exec:() -> Void) {
    haxe.Timer.delay(() -> exec(), 10);
  }
}
