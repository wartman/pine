package pine;

abstract class RootComponent extends ObjectComponent {
  public final child:Null<Component>;
  public final scheduler:Scheduler;

  public function new(props:{
    ?scheduler:Scheduler,
    ?child:Component
  }) {
    super(null);
    scheduler = props.scheduler == null ? DefaultScheduler.getInstance() : props.scheduler;
    child = props.child;
  }

  function createObject(_:Root) {
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
