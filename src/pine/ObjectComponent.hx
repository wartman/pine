package pine;

abstract class ObjectComponent extends Component {
  abstract public function getChildren():Array<Null<Component>>;

  abstract public function getApplicatorType():UniqueId;

  public function createObject(adapter:Adapter):Dynamic {
    return adapter.getApplicator(this).create(this);
  }

  public function updateObject(adapter:Adapter, object:Dynamic, ?previousComponent:Component):Dynamic {
    adapter.getApplicator(this).update(object, this, cast previousComponent);
    return object;
  }

  public function insertObject(adapter:Adapter, object:Dynamic, slot:Null<Slot>, findParent:() -> Dynamic) {
    adapter.getApplicator(this).insert(object, slot, findParent);
  }

  public function moveObject(adapter:Adapter, object:Dynamic, from:Null<Slot>, to:Null<Slot>, findParent:() -> Dynamic) {
    adapter.getApplicator(this).move(object, from, to, findParent);
  }

  public function removeObject(adapter:Adapter, object:Dynamic, slot:Null<Slot>) {
    adapter.getApplicator(this).remove(object, slot);
  }
}
