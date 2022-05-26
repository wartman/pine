package pine;

abstract class ObjectComponent extends Component {
  abstract public function getChildren():Array<Null<Component>>;

  abstract public function createObject(root:Root):Dynamic;

  abstract public function updateObject(root:Root, object:Dynamic, ?previousComponent:Component):Dynamic;

  public function insertObject(root:Root, object:Dynamic, slot:Null<Slot>, findParent:() -> Dynamic) {
    root.insertObject(object, slot, findParent);
  }

  public function moveObject(root:Root, object:Dynamic, from:Null<Slot>, to:Null<Slot>, findParent:() -> Dynamic) {
    root.moveObject(object, from, to, findParent);
  }

  public function removeObject(root:Root, object:Dynamic, slot:Null<Slot>) {
    root.removeObject(object, slot);
  }
}
