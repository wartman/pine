package pine.router;

class RouteVisitor implements Disposable {
  var visited:Array<String> = [];
  var pending:Array<String> = [];

  public function new() {}

  public function enqueue(path:String) {
    if (didVisit(path)) return;
    pending.push(path);
  }

  public function didVisit(path:String):Bool {
    return visited.contains(path) || pending.contains(path);
  }

  public function hasPending():Bool {
    return pending.length != 0;
  }

  public function drain():Array<String> {
    var toVisit = pending.copy();

    visited = visited.concat(toVisit);
    pending = [];
    
    return toVisit;
  }

  public function dispose() {}
}
