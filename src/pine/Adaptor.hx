package pine;

interface Adaptor {
  public function hydrate(scope:()->Void):Void;
  public function createContainerPrimitive(slot:Slot, findParent:()->Dynamic):Dynamic;
  public function createPrimitive(name:String, slot:Slot, findParent:()->Dynamic):Dynamic;
  public function createTextPrimitive(text:String, slot:Slot, findParent:()->Dynamic):Dynamic;
  public function updateTextPrimitive(primitive:Dynamic, value:String):Void;
  public function updatePrimitiveAttribute(primitive:Dynamic, name:String, value:Dynamic):Void;
  public function insertPrimitive(primitive:Dynamic, slot:Null<Slot>, findParent:()->Dynamic):Void;
  public function movePrimitive(primitive:Dynamic, from:Null<Slot>, to:Null<Slot>, findParent:()->Dynamic):Void;
  public function removePrimitive(primitive:Dynamic, slot:Null<Slot>):Void;
}
