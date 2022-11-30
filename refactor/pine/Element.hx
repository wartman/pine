package pine;

import pine.core.*;
import pine.debug.Debug;
import pine.element.*;
import pine.hydration.Cursor;

/**
  Elements are the persistant part of Pine. They're configured by
  Components, and most of their functionality is provided by various
  "Managers". Generally, you should not be creating subclasses of Element
  -- instead, use Components to configure the Managers the Element will
  use. For more fine-grained control, you can use LifecycleHooks.
**/
@:allow(pine)
class Element
  implements Context
  implements Disposable 
  implements DisposableHost 
{
  final hooks:LifecycleHooksManager = new LifecycleHooksManager();
  final disposables:DisposableManager = new DisposableManager();
  final object:ObjectManager;
  final slots:SlotManager;
  final children:ChildrenManager;
  final ancestors:AncestorManager;

  var component:Component;
  var status:ElementStatus = Pending;

  public function new(component) {
    this.component = component;
    this.object = component.createObjectManager(this);
    this.children = component.createChildrenManager(this);
    this.slots = component.createSlotManager(this);
    this.ancestors = component.createAncestorManager(this);
    this.hooks.add(component.createLifecycleHooks());
  }

  public function mount(parent:Null<Element>, newSlot:Null<Slot>) {
    init(parent, newSlot);

    status = Building;
    if (hooks.beforeInit != null) hooks.beforeInit(this);
    object.init();
    children.init();
    if (hooks.afterInit != null) hooks.afterInit(this);
    status = Valid;
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

  function init(parent:Null<Element>, newSlot:Null<Slot>) {
    Debug.assert(status == Pending, 'Attempted to mount an already mounted Element');
    
    ancestors.update(parent);
    slots.update(newSlot);

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
    
    if (status != Invalid) {
      return;
    }
    
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

    if (status == Invalid) {
      return;
    }

    status = Invalid;

    switch ancestors.getRoot() {
      case Some(root): root.requestRebuild(this);
      case None:
    }
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
    slots.update(newSlot);
  }

	public function getObject():Dynamic {
    return object.get();
  }

	public function getComponent<T:Component>():T {
    return cast component;
	}

  public function getRoot() {
    return ancestors.getRoot();
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
    object.dispose();
    slots.dispose();
    children.dispose();
    disposables.dispose();
  }
}
