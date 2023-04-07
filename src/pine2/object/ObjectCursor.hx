package pine2.object;

import kit.Assert;
import pine2.internal.Cursor;

class ObjectCursor implements Cursor {
  var object:Null<Object>;

  public function new(object) {
    this.object = object;
  }

  public function current():Null<Dynamic> {
    return object;
  }

  public function currentChildren():Cursor {
    if (object == null) return new ObjectCursor(null);
    return new ObjectCursor(object.children[0]);
  }

  public function next() {
    if (object == null) return;

    if (object.parent == null) {
      object = null;
      return;
    }

    assert(object != null);

    var parent = object.parent;
    var index = parent.children.indexOf(object);

    object = parent.children[index + 1];
  }

  public function move(current:Dynamic) {
    object = current;
  }

  public function clone() {
    return new ObjectCursor(object);
  }
}
