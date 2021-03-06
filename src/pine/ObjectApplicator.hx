package pine;

interface ObjectApplicator<T:ObjectComponent> {
  public function create(component:T):Dynamic;
  public function update(object:Dynamic, component:T, ?previousComponent:T):Void;
  public function insert(object:Dynamic, slot:Null<Slot>, findParent:() -> Dynamic):Void;
  public function move(object:Dynamic, from:Null<Slot>, to:Null<Slot>, findParent:() -> Dynamic):Void;
  public function remove(object:Dynamic, slot:Null<Slot>):Void;
}
