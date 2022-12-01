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
  use. For more fine-grained control, you can also create LifecycleHooks
  in a Component.
**/
@:allow(pine)
class Element
  implements Context
  implements Disposable 
  implements DisposableHost
  implements HasLazyProps 
{
  final hooks:LifecycleHooksManager = new LifecycleHooksManager();
  final disposables:DisposableManager = new DisposableManager();
  
  @lazy var object:ObjectManager = component.createObjectManager(this);
  @lazy var adapter:AdapterManager = component.createAdapterManager(this);
  @lazy var slots:SlotManager = component.createSlotManager(this);
  @lazy var children:ChildrenManager = component.createChildrenManager(this);
  @lazy var ancestors:AncestorManager = component.createAncestorManager(this);

  var component:Component;
  var status:ElementStatus = Pending;

  public function new(component) {
    this.component = component;
    this.hooks.add(component.createLifecycleHooks());
  }

  public function mount(parent:Null<Element>, newSlot:Null<Slot>) {
    init(parent, newSlot);

    hooks.beforeInit(this);

    status = Building;
    object.init();
    children.init();
    status = Valid;
    
    hooks.afterInit(this);
  }

  public function hydrate(cursor:Cursor, parent:Null<Element>, newSlot:Null<Slot>) {
    init(parent, newSlot);

    hooks.beforeHydrate(this, cursor);
    if (!hooks.shouldHydrate(this, cursor)) return;

    status = Building;
    object.hydrate(cursor);
    children.hydrate(cursor);
    status = Valid;
    
    hooks.afterHydrate(this, cursor);
  }

  function init(parent:Null<Element>, slot:Null<Slot>) {
    Debug.assert(status == Pending, 'Attempted to mount an already mounted Element');
    
    adapter.update(parent);
    ancestors.update(parent);
    slots.init(slot);

    status = Valid;
  }

  public function update(incomingComponent:Component) {
    Debug.assert(status != Building);
    
    hooks.beforeUpdate(this, component, incomingComponent);
    if (!hooks.shouldUpdate(this, component, incomingComponent, false)) return;

    status = Building;
    this.component = incomingComponent;
    object.update();
    children.update();
    status = Valid;

    hooks.afterUpdate(this);
  }

  public function rebuild() {
    Debug.assert(status != Building);
    if (status != Invalid) return;
    
    hooks.beforeUpdate(this, component, component);
    if (!hooks.shouldUpdate(this, component, component, true)) return;

    status = Building;
    object.update();
    children.update();
    status = Valid;
    
    hooks.afterUpdate(this);
  }

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
    Visit this element's children. The element will continue 
    to iterate through its children as long as `visitor` returns
    `true`.
  **/
  public function visitChildren(visitor) {
    children.visit(visitor);
  }

  public function updateSlot(newSlot:Slot) {
    var oldSlot = slots.get();
    slots.update(newSlot);
    hooks.onUpdateSlot(this, oldSlot, newSlot);
  }

	public function getObject():Dynamic {
    return object.get();
  }

	public function getComponent<T:Component>():T {
    return cast component;
	}

  public function getAdapter() {
    return adapter.get();
  }

  public function queryAncestors():AncestorQuery {
    return ancestors.getQuery();
  }

  public function queryChildren():ChildrenQuery {
    return children.getQuery();
  }

  public function addDisposable(disposable:DisposableItem) {
    disposables.addDisposable(disposable);
  }

  public function dispose() {
    Debug.assert(
      status != Building 
      && status != Disposing
      && status != Disposed
    );

    status = Disposing;

    hooks.onDispose(this);
    object.dispose();
    children.dispose();
    slots.dispose();
    disposables.dispose();

    status = Disposed;
  }
}
