package pine;

import pine.core.*;
import pine.debug.Debug;
import pine.element.*;
import pine.hydration.Cursor;

using pine.core.OptionTools;

/**
  Elements are the persistant part of Pine. They're configured by
  Components, and most of their functionality is provided by various
  "Managers". Generally, you should not be creating subclasses of Element
  -- instead, use Components to configure the Managers the Element will
  use.
**/
@:allow(pine)
class Element
  implements Context
  implements Disposable 
  implements DisposableHost
  implements HasLazyProps 
{
  final lifecycle:LifecycleManager = new LifecycleManager();
  final disposables:DisposableManager = new DisposableManager();
  
  @lazy var object:ObjectManager = component.createObjectManager(this);
  @lazy var adapter:AdapterManager = component.createAdapterManager(this);
  @lazy var hooks:HookCollection<Dynamic> = component.createHooks();
  @lazy var slots:SlotManager = component.createSlotManager(this);
  @lazy var children:ChildrenManager = component.createChildrenManager(this);
  @lazy var ancestors:AncestorManager = component.createAncestorManager(this);

  var component:Component;
  var status:ElementStatus = Pending;

  public function new(component) {
    this.component = component;
  }

  public function mount(parent:Null<Element>, newSlot:Null<Slot>) {
    init(parent, newSlot);

    lifecycle.beforeInit(this);

    status = Building;
    object.init();
    children.init();
    status = Valid;
    
    lifecycle.afterInit(this);
  }

  public function hydrate(cursor:Cursor, parent:Null<Element>, newSlot:Null<Slot>) {
    init(parent, newSlot);

    lifecycle.beforeInit(this);
    lifecycle.beforeHydrate(this, cursor);
    if (!lifecycle.shouldHydrate(this, cursor)) {
      lifecycle.afterHydrate(this, cursor);
      lifecycle.afterInit(this);
      return;
    }

    status = Building;
    object.hydrate(cursor);
    children.hydrate(cursor);
    status = Valid;
    
    lifecycle.afterHydrate(this, cursor);
    lifecycle.afterInit(this);
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
    
    lifecycle.beforeUpdate(this, component, incomingComponent);
    if (!lifecycle.shouldUpdate(this, component, incomingComponent, false)) {
      lifecycle.afterUpdate(this);
      return;
    }

    status = Building;
    this.component = incomingComponent;
    object.update();
    children.update();
    status = Valid;

    lifecycle.afterUpdate(this);
  }

  /**
    Mark this Element as invalid and enqeue it for rebuilding.
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
    
    lifecycle.beforeUpdate(this, component, component);
    if (!lifecycle.shouldUpdate(this, component, component, true)) {
      lifecycle.afterUpdate(this);
      return;
    }

    status = Building;
    object.update();
    children.update();
    status = Valid;
    
    lifecycle.afterUpdate(this);
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
    lifecycle.onUpdateSlot(this, oldSlot, newSlot);
  }

  /**
    Get this element's current Component.
  **/
  public function getComponent<T:Component>():T {
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
    Add a Disposible to be disposed when this Element is.
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

    lifecycle.onDispose(this);
    object.dispose();
    children.dispose();
    slots.dispose();
    disposables.dispose();

    status = Disposed;
  }
}
