package pine;

/**
  The primary use for a Scope is to get access to `Context` at
  a specific point in a component tree, or to quickly hook into
  the Element lifecycle (init, render and dispose).
**/
@:allow(pine.ScopeElement)
class Scope extends Component {
  static final type = new UniqueId();

  final init:Null<(context:InitContext)->Void>;
  final render:(context:Context) -> Component;
  final dispose:Null<(context:Context) -> Void>;

  public function new(props:{
    render:(context:Context) -> Component,
    ?init:(context:InitContext) -> Void,
    ?dispose:(context:Context) -> Void,
    ?key:Key
  }) {
    super(props.key);
    this.init = props.init;
    this.render = props.render;
    this.dispose = props.dispose;
  }

  public function getComponentType():UniqueId {
    return type;
  }

  function createElement():Element {
    return new ScopeElement(this);
  }
}

class ScopeElement extends Element {
  var child:Null<Element> = null;
  var scope(get, never):Scope;
  inline function get_scope():Scope return getComponent();

  public function new(scope:Scope) {
    super(scope);
  }

  function performDispose() {
    if (scope.dispose != null) scope.dispose(this);
  }

  function performHydrate(cursor:HydrationCursor) {
    child = hydrateElementForComponent(cursor, scope.render(this), slot);
    if (scope.init != null) scope.init(this);
  }

  function performBuild(previousComponent:Null<Component>) {
    child = updateChild(child, scope.render(this), slot);
    if (previousComponent == null && scope.init != null) scope.init(this);
  }

  public function visitChildren(visitor:ElementVisitor) {
    if (child != null) visitor.visit(child);
  }
}
