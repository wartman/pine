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
  var child:Null<Element> = null;

  public function new(component:Portal) {
    super(component);
  }

  override function dispose() {
    if (portalRoot != null) {
      portalRoot.dispose();
      portalRoot = null;
    }
    super.dispose();
  }

  function performHydrate(cursor:HydrationCursor) {
    Debug.assert(portalRoot == null);

    var portalCursor = cursor.clone();
    portalCursor.move(portal.target);
    
    portalRoot = createRoot(portal.child);
    portalRoot.hydrate(portalCursor, this);

    child = updateChild(null, Adapter.from(this).createPlaceholder(), slot);
  }

  function performBuild(previousComponent:Null<Component>) {
    if (portalRoot == null) {
      portalRoot = createRoot(portal.child);
      portalRoot.mount(this);
    } else if (
      previousComponent != null 
      && (cast previousComponent:Portal).target != portal.target
    ) {
      portalRoot.dispose();
      portalRoot = createRoot(portal.child);
      portalRoot.mount(this);
    } else {
      portalRoot.update(Adapter.from(this).createPortalRoot(portal.target, portal.child));
    }

    child = updateChild(child, Adapter.from(this).createPlaceholder(), slot);
  }

  public function visitChildren(visitor:ElementVisitor) {
    if (child != null) visitor.visit(child);
  }

  function createRoot(child) {
    var root = Adapter.from(this).createPortalRoot(portal.target, child).createElement();
    return root;
  }
}
