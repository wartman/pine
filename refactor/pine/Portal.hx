package pine;

import pine.core.*;
import pine.debug.Debug;
import pine.diffing.Key;
import pine.element.*;
import pine.element.proxy.*;
import pine.element.core.*;
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

  function createAdapterManager(element:Element):AdapterManager {
    return new CoreAdapterManager();
  }

  function createAncestorManager(element:Element):AncestorManager {
    return new CoreAncestorManager(element);
  }

  function createChildrenManager(element:Element):ChildrenManager {
    return new PortalChildrenManager(element);
  }

  function createSlotManager(element:Element):SlotManager {
    return new ProxySlotManager(element);
  }

  function createObjectManager(element:Element):ObjectManager {
    return new PortalObjectManager(element);
  }

  function createLifecycleHooks():Null<LifecycleHooks<Dynamic>> {
    return null;
  }
}

@:allow(pine)
class PortalChildrenManager implements ChildrenManager {
  final placeholder:ProxyChildrenManager;
  final element:ElementOf<Portal>;
  
  var previousComponent:Null<Portal> = null;
  var portalRoot:Null<Element> = null;
  
  public function new(element) {
    this.element = element;
    this.placeholder = new ProxyChildrenManager(element, context -> {
      var placeholder = context
        .getAdapter()
        .orThrow('Adapter expected')
        .createPlaceholder();
      return placeholder;
    });
  }

  public function visit(visitor:(child:Element) -> Bool) {
    if (portalRoot != null) portalRoot.visitChildren(visitor);
  }

  public function init() {
    placeholder.init();
    portalRoot = createRootComponent().createElement();
    portalRoot.mount(element, null);
  }

  public function hydrate(cursor:Cursor) {
    placeholder.update(); // Using update is intentional!

    var portalCursor = cursor.clone();
    portalCursor.move(element.getComponent().target);
    
    portalRoot = createRootComponent().createElement();
    portalRoot.hydrate(portalCursor, element, null);
  }

  public function update() {
    placeholder.update();

    if (portalRoot == null) {
      portalRoot = createRootComponent().createElement();
      portalRoot.mount(element, null);
    } else if (
      previousComponent != null
      && previousComponent.target != element.getComponent().target
    ) {
      portalRoot.dispose();
      portalRoot = createRootComponent().createElement();
      portalRoot.mount(element, null);
    } else {
      portalRoot.update(createRootComponent());
    }
  }

  public function getQuery():ChildrenQuery {
    throw new haxe.exceptions.NotImplementedException();
  }

  public function dispose() {
    if (portalRoot != null) {
      portalRoot.dispose();
      portalRoot = null;
    }
    previousComponent = null;
    placeholder.dispose();
  }

  function createRootComponent() {
    var adapter = element.getAdapter().orThrow('Expected an adapter');
    var component = element.getComponent();

    previousComponent = component;
    
    return adapter.createPortalRoot(component.target, component.child);
  }
}

class PortalObjectManager implements ObjectManager {
  final element:ElementOf<Portal>;

  public function new(element) {
    this.element = element;
  }

  public function get():Dynamic {
    // Note: The reason we need to use this class instead of the
    // default CoreObjectManager is that elements next to the Portal
    // will need to get its placeholder object to know where they
    // should be in the app.
    //
    // If we *dont* do this and just visit the Portal's children,
    // we'll end up getting an object in the Portal target.

    var children:PortalChildrenManager = cast element.children;
    var placeholder = children.placeholder;
    var object:Null<Dynamic> = null;

    placeholder.visit(element -> {
      Debug.assert(object == null, 'Element has more than one objects');
      object = element.getObject();
      true;
    });

    Debug.alwaysAssert(object != null, 'Element does not have an object');

    return object;
  }

  public function init() {}

  public function hydrate(cursor:Cursor) {}

  public function update() {}

  public function dispose() {}
}
