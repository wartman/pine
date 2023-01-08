package pine.object;

import pine.adaptor.ObjectApplicator;
import pine.debug.Debug;
import pine.element.*;

abstract class BaseObjectApplicator<T:ObjectComponent> implements ObjectApplicator<T> {
  public function new() {}

  abstract public function create(component:T):Dynamic;

  abstract public function update(object:Dynamic, component:T, previousComponent:Null<T>):Void;

  public function insert(object:Dynamic, slot:Null<Slot>, findParent:() -> Dynamic) {
    var obj:Object = object;
    if (slot != null && slot.previous != null) {
      var relative:Object = slot.previous.getObject();
      var parent = relative.parent;
      if (parent != null) {
        var index = parent.children.indexOf(relative);
        parent.insert(index + 1, obj);
      } else {
        var parent:Object = findParent();
        Debug.assert(parent != null);
        parent.prepend(obj);
      }
    } else {
      var parent:Object = findParent();
      Debug.assert(parent != null);
      parent.prepend(obj);
    }
  }

  public function move(object:Dynamic, from:Null<Slot>, to:Null<Slot>, findParent:() -> Dynamic) {
    var obj:Object = object;

    Debug.alwaysAssert(to != null);

    if (from != null && !from.indexChanged(to)) {
      return;
    }

    if (to.previous == null) {
      var parent:Object = findParent();
      Debug.assert(parent != null);
      parent.prepend(object);
      return;
    }

    var relative:Object = to.previous.getObject();
    var parent = relative.parent;

    Debug.alwaysAssert(parent != null);

    var index = parent.children.indexOf(relative);

    parent.insert(index + 1, obj);
  }

  public function remove(object:Dynamic, slot:Null<Slot>) {
    var obj:Object = object;
    obj.remove();
  }
}
