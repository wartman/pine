package pine;

import haxe.ds.Option;

using pine.Cast;

@:allow(pine)
class Portal extends Component {
  public static function getObjectMaybeInPortal(target:Element) {
    var object:Null<Dynamic> = null;

    function visit(el:Element) {
      Debug.assert(object == null, 'More then one object found');
      if (el is PortalElement) {
        switch el.as(PortalElement).getPortalRoot() {
          case Some(portal): 
            object = portal.getObject();
          case None if (el is ObjectElement): 
            object = el.getObject();
          case None: 
            el.visitChildren(visit);
        }
      } else if (el is ObjectElement) { 
        object = el.getObject();
      } else {
        el.visitChildren(visit);
      }
    }

    if (target is PortalElement) {
      switch target.as(PortalElement).getPortalRoot() {
        case Some(portal): return portal.getObject();
        case None:
      }
    }

    target.visitChildren(visit);

    Debug.assert(object != null, 'No object found');
    
    return object;
  }

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

@component(Portal)
class PortalElement extends Element {
  var portalRoot:Null<Element> = null;
  var child:Null<Element> = null;

  function performHydrate(cursor:HydrationCursor) {
    Debug.assert(portalRoot == null);

    var portalCursor = cursor.clone();
    portalCursor.move(portal.target);
    
    portalRoot = createRootElement();
    portalRoot.hydrate(portalCursor, this);

    child = updateChild(null, Adapter.from(this).createPlaceholder(), slot);
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

    child = updateChild(child, Adapter.from(this).createPlaceholder(), slot);
  }

  override function prepareForDisposal() {
    if (portalRoot != null) {
      portalRoot.dispose();
      portalRoot = null;
    }
    super.prepareForDisposal();
  }

  function performDispose() {}

  public function getPortalRoot():Option<Element> {
    return portalRoot == null ? None : Some(portalRoot);
  }

  public function visitChildren(visitor:ElementVisitor) {
    if (child != null) visitor.visit(child);
  }

  inline function createRootComponent() {
    return Adapter.from(this).createPortalRoot(portal.target, portal.child);
  }

  inline function createRootElement() {
    return createRootComponent().createElement();
  }
}
