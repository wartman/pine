package pine.html.client;

import js.html.Node;
import pine.internal.Cursor;

class ClientCursor implements Cursor {
  var node:Null<Node>;

  public function new(node) {
    this.node = node;
  }

  public function current():Null<Dynamic> {
    if (node != null && node.nodeType == Node.COMMENT_NODE) next();
    return node;
  }

  public function next() {
    if (node == null) return;
    node = node.nextSibling;
    if (node != null && node.nodeType == Node.COMMENT_NODE) next();
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
