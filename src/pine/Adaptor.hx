package pine;

interface Adaptor {
  public function createContainerPrimitive():Dynamic;
  public function createPrimitive(name:String):Dynamic;
  public function createPlaceholderPrimitive():Dynamic;
  public function createTextPrimitive(text:String):Dynamic;
  public function updateTextPrimitive(primitive:Dynamic, value:String):Void;
  public function updatePrimitiveAttribute(primitive:Dynamic, name:String, value:Dynamic, ?isHydrating:Bool):Void;
  public function insertPrimitive(primitive:Dynamic, slot:Null<Slot>, findParent:() -> Dynamic):Void;
  public function movePrimitive(primitive:Dynamic, from:Null<Slot>, to:Null<Slot>, findParent:() -> Dynamic):Void;
  public function removePrimitive(primitive:Dynamic, slot:Null<Slot>):Void;
}
