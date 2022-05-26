package pine;

abstract class RootElement extends ObjectElement implements Root {
  var child:Null<Element> = null;
  var isScheduled:Bool = false;
  var invalidElements:Null<Array<Element>> = null;
  public var rootComponent(get, never):RootComponent;

  inline function get_rootComponent():RootComponent {
    return cast component;
  }

  public function new(rootComponent:RootComponent) {
    super(rootComponent);
    parent = null; // @todo: We should allow Roots to have parents?
    root = this;
  }

  override function getRoot():Root {
    return this;
  }

  public function bootstrap() {
    mount(null);
  }

  override function performSetup(parent:Null<Element>, ?slot:Slot) {
    Debug.assert(parent == null, 'Root elements should not have a parent');
    this.slot = slot;
    status = Valid;
  }

  public function requestRebuild(child:Element) {
    if (child == this) {
      Debug.assert(status == Invalid);
      isScheduled = true;
      invalidElements = null;
      rootComponent.scheduler.schedule(() -> {
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
    rootComponent.scheduler.schedule(performRebuildInvalidElements);
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
      object = rootComponent.createObject(this);
    } else {
      if (previousComponent != component) rootComponent.updateObject(this, previousComponent);
    }
    performBuildChild();
  }

  function performHydrate(cursor:HydrationCursor) {
    object = cursor.current();
    var objects = cursor.currentChildren();
    var comp = (cast component : RootComponent).child;
    if (comp != null) {
      child = hydrateElementForComponent(objects, comp, slot);
      cursor.next();
    }
    Debug.assert(objects.current() == null);
  }

  function performBuildChild() {
    child = updateChild(child, (cast component : RootComponent).child, slot);
  }

  function visitChildren(visitor:ElementVisitor) {
    if (child != null) visitor.visit(child);
  }
}
