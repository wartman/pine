package pine.element;

import pine.core.Disposable;
import pine.hydration.Cursor;

interface ObjectManager extends Disposable {
  public function get():Dynamic;
  public function init():Void;
  public function hydrate(cursor:Cursor):Void;
  public function update():Void;
  public function move(oldSlot:Null<Slot>, newSlot:Null<Slot>):Void;
}
