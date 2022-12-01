package pine.html.client;

import pine.adapter.*;
import pine.debug.Debug;
import pine.element.*;

abstract class BaseClientApplicator<T:ObjectComponent> implements ObjectApplicator<T> {
  abstract public function create(component:T):Dynamic;

  abstract public function update(object:Dynamic, component:T, ?previousComponent:T):Void;

  public function new() {}

  public function insert(object:Dynamic, slot:Null<Slot>, findParent:() -> Dynamic) {
    var el:js.html.Element = object;
    if (slot != null && slot.previous != null) {
      var relative:js.html.Element = slot.previous.getObject();
      relative.after(el);
    } else {
      var parent:js.html.Element = findParent();
      Debug.assert(parent != null);
      parent.prepend(el);
    }
  }

  public function move(object:Dynamic, from:Null<Slot>, to:Null<Slot>, findParent:() -> Dynamic) {
    var el:js.html.Element = object;

    if (to == null) {
      if (from != null) {
        remove(object, from);
      }
      return;
    }

    if (from != null && !from.indexChanged(to)) {
      return;
    }

    if (to.previous == null) {
      var parent:js.html.Element = findParent();
      Debug.assert(parent != null);
      parent.prepend(el);
      return;
    }

    var relative:js.html.Element = to.previous.getObject();
    Debug.assert(relative != null);
    relative.after(el);
  }

  public function remove(object:Dynamic, slot:Null<Slot>) {
    var el:js.html.Element = object;
    el.remove();
  }
}
