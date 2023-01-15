package pine;

import pine.core.*;
import pine.debug.Debug;
import pine.diffing.Key;
import pine.element.*;
import pine.element.ElementEngine;
import pine.element.ProxyElementEngine;
import pine.hydration.Cursor;

using pine.core.OptionTools;

final class Portal extends Component implements HasComponentType {
  public final target:Dynamic;
  public final child:Component;

  public function new(props:{
    target:Dynamic,
    child:Component,
    ?key:Key
  }) {
    super(props.key);
    this.target = props.target;
    this.child = props.child;
  }

  function createElement() {
    return new Element(this, element -> new PortalElementEngine(element), []);
  }
}

class PortalElementEngine implements ElementEngine {
  final element:ElementOf<Portal>;
  var placeholder:Null<Element> = null;
  var previousComponent:Null<Portal> = null;
  var portalRoot:Null<Element> = null;

  public function new(element) {
    this.element = element;
  }

  public function init() {
    placeholder = createPlaceholderComponent().createElement();
    placeholder.mount(element, element.slot);
    
    portalRoot = createRootComponent().createElement();
    portalRoot.mount(element, null);
  }

  public function hydrate(cursor:Cursor) {
    placeholder = createPlaceholderComponent().createElement();
    placeholder.mount(element, element.slot);

    var portalCursor = cursor.clone();
    portalCursor.move(element.component.target);
    
    portalRoot = createRootComponent().createElement();
    portalRoot.hydrate(portalCursor, element, null);
  }

  public function update() {
    Debug.assert(placeholder != null);
    placeholder.update(createPlaceholderComponent());

    if (portalRoot == null) {
      portalRoot = createRootComponent().createElement();
      portalRoot.mount(element, null);
    } else if (
      previousComponent != null
      && previousComponent.target != element.component.target
    ) {
      portalRoot.dispose();
      portalRoot = createRootComponent().createElement();
      portalRoot.mount(element, null);
    } else {
      portalRoot.update(createRootComponent());
    }
  }

  public function getAdaptor() {
    return findParentAdaptor(element);
  }

  public function getObject():Dynamic {
    Debug.assert(placeholder != null);
    return placeholder.getObject();
  }

  public function createSlot(index:Int, previous:Null<Element>):Slot {
    return new Slot(index, previous);
  }

  public function updateSlot(slot:Null<Slot>) {
    Debug.assert(placeholder != null);
    element.slot = slot;
    placeholder.updateSlot(slot);
  }

  public function visitChildren(visitor:(child:Element) -> Bool) {
    if (portalRoot != null) portalRoot.visitChildren(visitor);
  }

  public function createChildrenQuery():ChildrenQuery {
    return new ChildrenQuery(element);
  }

  public function createAncestorQuery():AncestorQuery {
    return new AncestorQuery(element);
  }

  public function handleThrownObject(target:Element, e:Dynamic) {
    bubbleThrownObjectUp(element, target, e);
  }

  public function dispose() {
    if (placeholder != null) {
      placeholder.dispose();
      placeholder = null;
    }
    if (portalRoot != null) {
      portalRoot.dispose();
      portalRoot = null;
    }
    previousComponent = null;
  }

  function createPlaceholderComponent() {
    var adaptor = element.getAdaptor().orThrow('Adaptor expected');
    return adaptor.createPlaceholder();
  }
  
  function createRootComponent() {
    var adaptor = element.getAdaptor().orThrow('Expected an adaptor');
    var component = element.component;

    previousComponent = component;
    
    return adaptor.createPortalRoot(component.target, component.child);
  }
}
