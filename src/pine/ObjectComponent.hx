package pine;

abstract class ObjectComponent extends Component {
  abstract public function getChildren():Array<Null<Component>>;

  abstract public function getApplicatorType():UniqueId;

  public function createObject(root:Root):Dynamic {
    return root.getApplicator(this).create(this);
  }

  public function updateObject(root:Root, object:Dynamic, ?previousComponent:Component):Dynamic {
    root.getApplicator(this).update(object, this, cast previousComponent);
    return object;
  }

  public function insertObject(root:Root, object:Dynamic, slot:Null<Slot>, findParent:() -> Dynamic) {
    root.getApplicator(this).insert(object, slot, findParent);
  }

  public function moveObject(root:Root, object:Dynamic, from:Null<Slot>, to:Null<Slot>, findParent:() -> Dynamic) {
    root.getApplicator(this).move(object, from, to, findParent);
  }

  public function removeObject(root:Root, object:Dynamic, slot:Null<Slot>) {
    root.getApplicator(this).remove(object, slot);
  }
}
