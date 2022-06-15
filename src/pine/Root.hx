package pine;

interface Root {
  public function getApplicator<T:ObjectComponent>(component:T):ObjectApplicator<T>;
  public function getDefaultApplicator():ObjectApplicator<ObjectComponent>;
  public function requestRebuild(element:Element):Void;
  // public function insertObject(object:Dynamic, slot:Null<Slot>, findParent:() -> Dynamic):Void;
  // public function moveObject(object:Dynamic, from:Null<Slot>, to:Null<Slot>, findParent:() -> Dynamic):Void;
  // public function removeObject(object:Dynamic, slot:Null<Slot>):Void;
  public function createPlaceholderObject(component:Component):Dynamic;
}
