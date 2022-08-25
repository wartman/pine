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

  override function performSetup(parent:Null<Element>, ?slot:Slot) {
    super.performSetup(parent, slot);

    portalRoot = getRoot().createPortalRoot(portal.target, null).createElement();
    portalRoot.mount(null);
  }

  override function dispose() {
    if (portalRoot != null) {
      portalRoot.dispose();
      portalRoot = null;
    }
    super.dispose();
  }

  function performHydrate(cursor:HydrationCursor) {
    // noop?
  }

  function performBuild(previousComponent:Null<Component>) {
    if (
      previousComponent != null 
      && (cast previousComponent:Portal).target != portal.target 
      && portalRoot != null
    ) {
      portalRoot.dispose();
      portalRoot = getRoot().createPortalRoot(portal.target, portal.child).createElement();
    } else if (portalRoot != null) {
      portalRoot.update(getRoot().createPortalRoot(portal.target, portal.child));
    }

    child = updateChild(child, getRoot().createPlaceholder(), slot);
  }

  public function visitChildren(visitor:ElementVisitor) {
    if (child != null) visitor.visit(child);
  }
}
