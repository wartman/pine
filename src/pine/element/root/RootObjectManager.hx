package pine.element.root;

import haxe.ds.Option;
import pine.hydration.Cursor;

using pine.core.OptionTools;

class RootObjectManager implements ObjectManager {
  final element:ElementOf<RootComponent>;

  var object:Option<Dynamic> = None;

  public function new(element) {
    this.element = element;
  }

  public function get():Dynamic {
    return switch object {
      case Some(obj): 
        obj;
      case None:
        var obj = element.component.getRootObject();
        object = Some(obj);
        obj;
    }
  }

  public function init() {}

  public function hydrate(cursor:Cursor) {}

  public function update() {}

  public function move(oldSlot:Null<Slot>, newSlot:Null<Slot>) {}

  public function dispose() {
    object = None;
  }
}
