package pine;

@:allow(pine)
class Portal extends Component {
  public static final type = new UniqueId();

  final target:Dynamic;
  final child:Component;

  public function new(props:{
    target:Dynamic,
    child:Component,
    ?key:Key
  }) {
    super(props.key);
    this.target = props.target;
    this.child = props.child;
  }

  public function getComponentType():UniqueId {
    return type;
  }

  public function createElement():Element {
    return new PortalElement(this);
  }
}

class PortalElement extends Element {
  var portal(get, never):Portal;
  inline function get_portal():Portal {
    return getComponent();
  }

  var portalRoot:Null<Element> = null;
  final child:SingleChild;

  public function new(component:Portal) {
    super(component);
    child = new SingleChild(
      () -> Adapter.from(this).createPlaceholder(),
      new DefaultElementFactory(this)
    );
  }

  function performDispose() {
    if (portalRoot != null) {
      portalRoot.dispose();
      portalRoot = null;
    }
    child.dispose();
  }

  function performHydrate(cursor:HydrationCursor) {
    Debug.assert(portalRoot == null);

    var portalCursor = cursor.clone();
    portalCursor.move(portal.target);
    
    portalRoot = createRootElement();
    portalRoot.hydrate(portalCursor, this);

    child.update(null, slot);
  }

  function performBuild(previousComponent:Null<Component>) {
    if (portalRoot == null) {
      portalRoot = createRootElement();
      portalRoot.mount(this);
    } else if (
      previousComponent != null 
      && (cast previousComponent:Portal).target != portal.target
    ) {
      portalRoot.dispose();
      portalRoot = createRootElement();
      portalRoot.mount(this);
    } else {
      portalRoot.update(createRootComponent());
    }

    child.update(previousComponent, slot);
  }

  function performUpdateSlot(?slot:Slot) {
    child.visit(child -> child.updateSlot(slot));
  }

  public function visitChildren(visitor:ElementVisitor) {
    child.visit(visitor);
  }

  inline function createRootComponent() {
    return Adapter.from(this).createPortalRoot(portal.target, portal.child);
  }

  inline function createRootElement() {
    return createRootComponent().createElement();
  }
}
