package pine.internal;

interface Adaptor {
  public function createElementObject(name:String, initialAttrs:{}):Dynamic;
  public function createTextObject(value:String):Dynamic;
  public function createPlaceholderObject():Dynamic;
  public function createCursor(object:Dynamic):Cursor;
  // public function mountPortal(target:Dynamic, build:()->Component):Component;
  public function updateTextObject(object:Dynamic, value:String):Void;
  public function updateObjectAttribute(object:Dynamic, name:String, value:Dynamic):Void;
  public function insertObject(object:Dynamic, slot:Null<Slot>, findParent:() -> Dynamic):Void;
  public function moveObject(object:Dynamic, from:Null<Slot>, to:Null<Slot>, findParent:() -> Dynamic):Void;
  public function removeObject(object:Dynamic, slot:Null<Slot>):Void;
}
