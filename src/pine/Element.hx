package pine;

import pine.core.*;
import pine.debug.Debug;
import pine.element.*;
import pine.hydration.Cursor;

using pine.core.OptionTools;

/**
  Elements are the persistent part of Pine. They're configured by
  Components, and most of their functionality is provided by various
  "Managers" that they compose. While you *could* create a subclass
  of an Element, generally you should be able to do everything
  you need by changing one of the managers an Element uses (and Pine
  already has a lot, mostly found in the `pine.element` package).
  Generally you won't even need to do that: AutoComponents and
  Hooks should nearly every use case you need.
**/
@:allow(pine)
class Element
  implements Context
  implements Disposable 
  implements DisposableHost
  implements HasLazyProps 
{
  final events:EventManager<Dynamic> = new EventManager();
  final disposables:DisposableManager = new DisposableManager();
  
  @:lazy var object:ObjectManager = component.createObjectManager(this);
  @:lazy var adapter:AdapterManager = component.createAdapterManager(this);
  @:lazy var hooks:HookCollection<Dynamic> = component.createHooks();
  @:lazy var slots:SlotManager = component.createSlotManager(this);
  @:lazy var children:ChildrenManager = component.createChildrenManager(this);
  @:lazy var ancestors:AncestorManager = component.createAncestorManager(this);

  var component:Component;
  var status:ElementStatus = Pending;

  public function new(component) {
    this.component = component;
  }

  /**
    Mount this element using whatever adapter you've decided to use.

    This will initialize the element and all its managers.
  **/
  public function mount(parent:Null<Element>, newSlot:Null<Slot>) {
    init(parent, newSlot);

    events.beforeInit.dispatch(this, Normal);

    status = Building;
    object.init();
    children.init();
    status = Valid;
    
    events.afterInit.dispatch(this, Normal);
  }

  /**
    Hydrate an existing target.
    
    This will initialize the element and all its managers. Note that
    you should NOT run `mount` and `initialize` on the same Element.
  **/
  public function hydrate(cursor:Cursor, parent:Null<Element>, newSlot:Null<Slot>) {
    init(parent, newSlot);

    events.beforeInit.dispatch(this, Hydrating(cursor));

    status = Building;
    object.hydrate(cursor);
    children.hydrate(cursor);
    status = Valid;
    
    events.afterInit.dispatch(this, Hydrating(cursor));
  }

  function init(parent:Null<Element>, slot:Null<Slot>) {
    Debug.assert(status == Pending, 'Attempted to mount an already mounted Element');
    
    adapter.update(parent);
    ancestors.update(parent);
    slots.init(slot);
    hooks.init(this);

    status = Valid;
  }

  /**
    Updates this Element's configuration with a new Component.

    Note that this *will not* update the Element's managers.
  **/
  public function update(incomingComponent:Component) {
    Debug.assert(status != Building);
    
    events.beforeUpdate.dispatch(this, component, incomingComponent);

    status = Building;
    this.component = incomingComponent;
    object.update();
    children.update();
    status = Valid;

    events.afterUpdate.dispatch(this);
  }

  /**
    Mark this Element as invalid and enqueue it for rebuilding.
  **/
  public function invalidate() {
    Debug.assert(status != Pending, 'Attempted to invalidate an Element before it was mounted');
    Debug.assert(status != Disposed, 'Attempted to invalidate an Element after it was disposed');
    Debug.assert(status != Building, 'Attempted to invalidate an Element while it was building');
    
    if (status == Invalid) return;

    status = Invalid;

    adapter
      .get()
      .orThrow('No adapter found')
      .requestRebuild(this);
  }

  /**
    Update this element without changing its component.
    
    Note that you will probably never call this directly -- use `invalidate`
    instead.
  **/
  public function rebuild() {
    Debug.assert(status != Building);
    if (status != Invalid) return;
    
    events.beforeUpdate.dispatch(this, component, component);

    status = Building;
    object.update();
    children.update();
    status = Valid;
    
    events.afterUpdate.dispatch(this);
  }

  /**
    Visit this element's children. The element will continue 
    to iterate through its children as long as `visitor` returns
    `true`.
  **/
  public function visitChildren(visitor) {
    children.visit(visitor);
  }

  /**
    Update the Element's Slot -- the way it tracks its position
    in the Element tree.
    
    Note: This is mostly an internal detail. You should never
    have to use this unless you're creating an Adapter.
  **/
  public function updateSlot(newSlot:Slot) {
    var oldSlot = slots.get();
    slots.update(newSlot);
    object.move(oldSlot, newSlot);
    events.slotUpdated.dispatch(this, oldSlot, newSlot);
  }

  /**
    Get this element's current Component and auto-cast it to 
    the requested type.
  **/
  public inline function getComponent<T:Component>():T {
    return cast component;
  }
  
  /**
    Get the closest object for this element.

    An `object` is the lower-level implementation of the UI
    -- for example, if you're using the `pine.html.client`,
    `getObject` will return a `js.html.Node`, while the same
    element using the adapter from `pine.html.server` will
    return a `pine.object.Object`.
  **/
  public function getObject():Dynamic {
    return object.get();
  }

  /**
    Get the current `Adapter` this element is using. Adapters
    provide the bridge between Pine's Element tree and whatever
    platform the app is running on. For example, the 
    `pine.html.client.ClientAdapter` is responsible for actually
    adding, removing and updating the DOM based on the current state 
    of the app.
  **/
  public function getAdapter() {
    return adapter.get();
  }

  /**
    Query this component's ancestors.
  **/
  public function queryAncestors():AncestorQuery {
    return ancestors.getQuery();
  }

  /**
    Query this component's children.
  **/
  public function queryChildren():ChildrenQuery {
    return children.getQuery();
  }

  /**
    Add a Disposable to be disposed when this Element is.
  **/
  public function addDisposable(disposable:DisposableItem) {
    disposables.addDisposable(disposable);
  }

  /**
    Dispose this element, removing it from the Element tree
    and further disposing all of its managers.

    Note: you should almost *never* call this directly.
  **/
  public function dispose() {
    Debug.assert(
      status != Building 
      && status != Disposing
      && status != Disposed
    );

    status = Disposing;

    events.beforeDispose.dispatch(this);
    
    object.dispose();
    children.dispose();
    slots.dispose();
    disposables.dispose();

    status = Disposed;
    
    events.afterDispose.dispatch();
  }
}
