package pine;

abstract class RootElement extends ObjectElement implements Root {
  var child:Null<Element> = null;
  var isScheduled:Bool = false;
  var invalidElements:Null<Array<Element>> = null;
  final applicators:ObjectApplicatorCollection;

  public var rootComponent(get, never):RootComponent;
  inline function get_rootComponent():RootComponent {
    return cast component;
  }

  public function new(rootComponent:RootComponent, applicators) {
    super(rootComponent);
    this.applicators = applicators;
    parent = null; // @todo: We should allow Roots to have parents?
    root = this;
  }

  public function getApplicator<T:ObjectComponent>(component:T):ObjectApplicator<T> {
    return applicators.getForComponent(component);
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
      Process.defer(() -> {
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
    Process.defer(performRebuildInvalidElements);
  }

  function performRebuildInvalidElements() {
    Process.scope(() -> {
      isScheduled = false;
  
      if (invalidElements == null) {
        return;
      }
  
      var elements = invalidElements.copy();
      invalidElements = null;
      for (el in elements) el.rebuild();
    });
  }

  function performBuild(previousComponent:Null<Component>) {
    Process.scope(() -> {
      if (previousComponent == null) {
        object = rootComponent.createObject(this);
      } else {
        if (previousComponent != component) rootComponent.updateObject(this, previousComponent);
      }
      child = updateChild(child, (cast component : RootComponent).child, slot);
    });
  }

  function performHydrate(cursor:HydrationCursor) {
    Process.scope(() -> {
      object = cursor.current();
      var objects = cursor.currentChildren();
      var comp = (cast component : RootComponent).child;
      if (comp != null) {
        child = hydrateElementForComponent(objects, comp, slot);
        cursor.next();
      }
      Debug.assert(objects.current() == null);
    });
  }

  function visitChildren(visitor:ElementVisitor) {
    if (child != null) visitor.visit(child);
  }
}
