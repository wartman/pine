package pine.render;

abstract class Object {
  public var parent:Null<Object> = null;
  public var children:Array<Object> = [];

  public function prepend(child:Object) {
    Debug.assert(child != this);

    if (child.parent != null) child.remove();

    child.parent = this;
    children.unshift(child);
  }

  public function append(child:Object) {
    Debug.assert(child != this);

    if (child.parent != null) child.remove();

    child.parent = this;
    children.push(child);
  }

  public function insert(pos:Int, child:Object) {
    Debug.assert(child != this);

    if (child.parent != this && child.parent != null) child.remove();

    child.parent = this;

    if (!children.contains(child)) {
      children.insert(pos, child);
      return;
    }

    if (pos >= children.length) {
      pos = children.length;
    }

    var from = children.indexOf(child);

    if (pos == from) return;

    if (from < pos) {
      var i = from;
      while (i < pos) {
        children[i] = children[i + 1];
        i++;
      }
    } else {
      var i = from;
      while (i > pos) {
        children[i] = children[i - 1];
        i--;
      }
    }

    children[pos] = child;
  }

  public function remove() {
    if (parent != null) {
      parent.children.remove(this);
    }
    parent = null;
  }

  abstract public function toString():String;
}
