package pine;

class RootElement extends ObjectElement implements Root {
  final adapter:Adapter;
  var child:Null<Element> = null;
  var isScheduled:Bool = false;
  var invalidElements:Null<Array<Element>> = null;

  public var rootComponent(get, never):RootComponent;
  inline function get_rootComponent():RootComponent {
    return cast component;
  }

  public function new(rootComponent:RootComponent, adapter) {
    super(rootComponent);
    this.adapter = adapter;
  }

  public function getAdapter() {
    return adapter;
  }

  override function getRoot():Root {
    return this;
  }

  public function bootstrap() {
    mount(null);
  }

  public function requestRebuild(child:Element) {
    if (child == this) {
      Debug.assert(status == Invalid);
      isScheduled = true;
      invalidElements = null;
      adapter.getProcess().defer(() -> {
        rebuild();
        isScheduled = false;
      });
      return;
    }

    if (status == Invalid) return;
    Debug.assert(status == Valid);

    if (invalidElements == null) {
      invalidElements = [];
      scheduleRebuildInvalidElements();
    }

    if (invalidElements.contains(child)) return;
    invalidElements.push(child);
  }

  function scheduleRebuildInvalidElements() {
    if (isScheduled) return;
    isScheduled = true;
    adapter.getProcess().defer(performRebuildInvalidElements);
  }

  function performRebuildInvalidElements() {
    isScheduled = false;

    if (invalidElements == null) {
      return;
    }

    var elements = invalidElements.copy();
    invalidElements = null;
    for (el in elements) el.rebuild();
  }

  function performBuild(previousComponent:Null<Component>) {
    if (previousComponent == null) {
      object = rootComponent.createObject(adapter);
    } else {
      if (previousComponent != component) rootComponent.updateObject(adapter, previousComponent);
    }
    child = updateChild(child, rootComponent.child, createSlotForChild(0, null));
  }

  function performHydrate(cursor:HydrationCursor) {
    object = cursor.current();
    var objects = cursor.currentChildren();
    var comp = rootComponent.child;
    if (comp != null) {
      child = hydrateElementForComponent(objects, comp, createSlotForChild(0, null));
      cursor.next();
    }
    Debug.assert(objects.current() == null);
  }

  function visitChildren(visitor:ElementVisitor) {
    if (child != null) visitor.visit(child);
  }
}
