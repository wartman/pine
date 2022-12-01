package pine.html.client;

import js.html.Node;
import pine.hydration.Cursor;

class ClientCursor implements Cursor {
  var node:Null<Node>;

  public function new(node) {
    this.node = node;
  }

  public function current():Null<Dynamic> {
    return node;
  }

  public function next() {
    if (node == null) return;
    node = node.nextSibling;
  }

  public function currentChildren():Cursor {
    if (node == null) return new ClientCursor(null);
    return new ClientCursor(node.firstChild);
  }

  public function move(current:Dynamic) {
    node = current;
  }

  public function clone():Cursor {
    return new ClientCursor(node);
  }
}
