package pine;

abstract class View implements Disposable implements Context {
  public final parent:Null<View>;
  public final adaptor:Adaptor;
  
  var slot:Null<Slot>;

  public function new(parent, adaptor, slot) {
    this.parent = parent;
    this.adaptor = adaptor;
    this.slot = slot;
  }

  public function get<T>(type:Class<T>):Null<T> {
    return parent?.get(type);
  }

  abstract public function findNearestPrimitive():Dynamic;
  abstract public function getPrimitive():Dynamic;
  abstract public function getSlot():Null<Slot>;
  abstract public function setSlot(slot:Null<Slot>):Void;
}
