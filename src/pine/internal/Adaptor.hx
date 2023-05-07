package pine.internal;

interface Adaptor {
  public function createContainerObject(attrs:{}):Dynamic;
  public function createButtonObject(attrs:{}):Dynamic;
  public function createInputObject(attrs:{}):Dynamic;
  public function createCustomObject(name:String, attrs:{}):Dynamic;
  public function createPlaceholderObject():Dynamic;
  public function createTextObject(text:String):Dynamic;
  public function createCursor(object:Dynamic):Cursor;
  public function updateTextObject(object:Dynamic, value:String):Void;
  public function updateObjectAttribute(object:Dynamic, name:String, value:Dynamic, ?isHydrating:Bool):Void;
  public function insertObject(object:Dynamic, slot:Null<Slot>, findParent:() -> Dynamic):Void;
  public function moveObject(object:Dynamic, from:Null<Slot>, to:Null<Slot>, findParent:() -> Dynamic):Void;
  public function removeObject(object:Dynamic, slot:Null<Slot>):Void;
}
