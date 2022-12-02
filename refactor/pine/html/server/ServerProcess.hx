package pine.html.server;

import pine.adapter.Process;

class ServerProcess extends Process {
  function nextFrame(exec:() -> Void) {
    haxe.Timer.delay(() -> exec(), 10);
  }
}
