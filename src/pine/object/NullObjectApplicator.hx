package pine.object;

import pine.element.Slot;
import pine.adaptor.ObjectApplicator;

class NullObjectApplicator implements ObjectApplicator<Dynamic> {
  public function new() {}

  public function create(component:Dynamic):Dynamic {
    throw 'Cannot create objects using a NullObjectApplicator';
  }

  public function update(object:Dynamic, component:Dynamic, previousComponent:Null<Dynamic>) {}

  public function insert(object:Dynamic, slot:Null<Slot>, findParent:() -> Dynamic) {}

  public function move(object:Dynamic, from:Null<Slot>, to:Null<Slot>, findParent:() -> Dynamic) {}

  public function remove(object:Dynamic, slot:Null<Slot>) {}
}
