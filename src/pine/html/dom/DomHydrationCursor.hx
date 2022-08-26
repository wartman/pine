package pine.html.dom;

import js.html.Node;

class DomHydrationCursor implements HydrationCursor {
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

  public function currentChildren():HydrationCursor {
    if (node == null) return new DomHydrationCursor(null);
    return new DomHydrationCursor(node.firstChild);
  }

  public function move(current:Dynamic) {
    node = current;
  }

  public function clone():HydrationCursor {
    return new DomHydrationCursor(node);
  }
}
