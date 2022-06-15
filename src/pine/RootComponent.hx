package pine;

abstract class RootComponent extends ObjectComponent {
  public final child:Null<Component>;

  public function new(props:{ ?child:Component }) {
    super(null);
    child = props.child;
  }

  override function createObject(_:Root) {
    return getRootObject();
  }

  public function getChildren() {
    return [child];
  }

  abstract public function getRootObject():Dynamic;

  override function insertObject(root:Root, object:Dynamic, slot:Null<Slot>, findParent:() -> Dynamic) {
    throw 'Invalid action on a root object';
  }

  override function moveObject(root:Root, object:Dynamic, from:Null<Slot>, to:Null<Slot>, findParent:() -> Dynamic) {
    throw 'Invalid action on a root object';
  }

  override function removeObject(root:Root, object:Dynamic, slot:Null<Slot>) {
    throw 'Invalid action on a root object';
  }
}
