package pine;

import haxe.ds.Option;
import pine.adaptor.Adaptor;
import pine.core.*;
import pine.debug.Debug;
import pine.element.*;
import pine.element.ElementEngine;
import pine.element.Events;
import pine.element.Slot;
import pine.hydration.Cursor;

using pine.core.OptionTools;

@:allow(pine)
@:allow(pine.debug)
class Element
  implements Context
  implements Disposable 
  implements DisposableHost
{
  public final events:Events<Dynamic> = new Events();
  public final disposables:DisposableManager = new DisposableManager();
  public final engine:ElementEngine;

  var component:Component;
  var status:ElementStatus = Pending;
  var slot:Null<Slot> = null;
  var parent:Null<Element> = null;
  var adaptor:Null<Adaptor> = null;

  public function new(component, createEngine:CreateElementEngine) {
    this.component = component;
    this.engine = createEngine(this); // Must come last.
  }

  /**
    Mount this element using whatever adaptor you've decided to use.

    This will initialize the element and all its managers.
  **/
  public function mount(parent:Null<Element>, newSlot:Null<Slot>) {
    init(parent, newSlot);

    events.beforeInit.dispatch(this, Normal);

    status = Building;
    engine.init();
    if (status != Invalid) status = Valid;
    
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
    engine.hydrate(cursor);

    if (status != Invalid) status = Valid;
  
    events.afterInit.dispatch(this, Hydrating(cursor));
  }

  function init(parent:Null<Element>, slot:Null<Slot>) {
    Debug.assert(status == Pending, 'Attempted to mount an already mounted Element');
    
    this.parent = parent;
    this.slot = slot;
    this.adaptor = engine.getAdaptor();
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
    engine.update();
    if (status != Invalid) status = Valid;

    events.afterUpdate.dispatch(this);
  }

  /**
    Mark this Element as invalid and enqueue it for rebuilding.
  **/
  public function invalidate() {
    Debug.assert(status != Pending, 'Attempted to invalidate an Element before it was mounted');
    Debug.assert(status != Disposing, 'Attempted to invalidate an Element while it was disposing');
    Debug.assert(status != Disposed, 'Attempted to invalidate an Element after it was disposed');
    // Debug.assert(status != Building, 'Attempted to invalidate an Element while it was building');
    
    switch status {
      case Invalid: return;
      default:
    }

    status = Invalid;

    getAdaptor().requestRebuild(this);
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
    engine.update();
    if (status != Invalid) status = Valid;
    
    events.afterUpdate.dispatch(this);
  }

  /**
    Visit this element's children. The element will continue 
    to iterate through its children as long as `visitor` returns
    `true`.
  **/
  public function visitChildren(visitor) {
    engine.visitChildren(visitor);
  }

  /**
    Create a new slot using this Element's engine implementation.
  **/
  public function createSlot(index:Int, previous:Null<Element>) {
    return engine.createSlot(index, previous);
  }

  /**
    Update the Element's Slot -- the way it tracks its position
    in the Element tree.
    
    Note: This is mostly an internal detail. You should never
    have to use this unless you're creating an Adaptor.
  **/
  public function updateSlot(newSlot:Null<Slot>) {
    var oldSlot = slot;
    engine.updateSlot(newSlot);
    events.slotUpdated.dispatch(this, oldSlot, this.slot);
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
    element using the adaptor from `pine.html.server` will
    return a `pine.object.Object`.
  **/
  public function getObject():Dynamic {
    return engine.getObject();
  }

  /**
    Get the current `Adaptor` this element is using. Adaptors
    provide the bridge between Pine's Element tree and whatever
    platform the app is running on. For example, the 
    `pine.html.client.ClientAdaptor` is responsible for actually
    adding, removing and updating the DOM based on the current state 
    of the app.
  **/
  public function getAdaptor():Adaptor {
    if (adaptor == null) {
      adaptor = engine.getAdaptor();
    }
    return adaptor;
  }

  /**
    Get this Element's parent, if any.
  **/
  public function getParent():Option<Element> {
    return parent == null ? None : Some(parent);
  }

  /**
    Query this component's ancestors.
  **/
  public function queryAncestors():AncestorQuery {
    return engine.createAncestorQuery();
  }

  /**
    Query this component's children.
  **/
  public function queryChildren():ChildrenQuery {
    return engine.createChildrenQuery();
  }

  /**
    Add a Disposable to be disposed when this Element is.
  **/
  public function addDisposable(disposable:DisposableItem) {
    disposables.addDisposable(disposable);
  }

  /**
    Dispose this element, removing it from the Element tree.

    Note: you should almost *never* call this directly.
  **/
  public function dispose() {
    Debug.assert(status != Building, 'Attempted to dispose an element while it was building');
    Debug.assert(status != Disposing, 'Attempted to dispose an element this is already Disposing');
    Debug.assert(status != Disposed, 'Attempted to dispose an element that was already disposed');

    status = Disposing;

    events.beforeDispose.dispatch(this);
    
    engine.dispose();
    disposables.dispose();

    slot = null;

    status = Disposed;
    
    events.afterDispose.dispatch();
  }
}
