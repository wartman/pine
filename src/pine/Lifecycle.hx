package pine;

class Lifecycle extends Component {
  static final type = new UniqueId();

  public final render:(context:Context) -> Component;
  public final onMount:Null<(context:Context) -> Void>;
  public final onUpdate:Null<(context:Context) -> Void>;
  public final onDispose:Null<(context:Context) -> Void>;
  public final afterUpdate:Null<(context:Context) -> Void>;
  public final afterFrame:Null<(context:Context) -> Void>;

  public function new(props:{
    render:(context:Context) -> Component,
    ?onMount:(context:Context) -> Void,
    ?onUpdate:(context:Context) -> Void,
    ?onDispose:(context:Context) -> Void,
    ?afterUpdate:(context:Context) -> Void,
    ?afterFrame:(context:Context) -> Void,
    ?key:Key
  }) {
    super(props.key);
    render = props.render;
    onMount = props.onMount;
    onUpdate = props.onUpdate;
    onDispose = props.onDispose;
    afterUpdate = props.afterUpdate;
    afterFrame = props.afterFrame;
  }

  public function getComponentType():UniqueId {
    return type;
  }

  public function createElement():Element {
    return new LifecycleElement(this);
  }
}

class LifecycleElement extends Element {
  var lifecycle(get, never):Lifecycle;
  var child:Null<Element> = null;

  inline function get_lifecycle():Lifecycle {
    return cast component;
  }

  function before() {
    var update = lifecycle.onUpdate;
    if (update != null) {
      update(this);
    }
  }

  function after() {
    var update = lifecycle.afterUpdate;
    var frame = lifecycle.afterFrame;
    if (update != null) {
      update(this);
    }
    if (frame != null) {
      getRoot().observe().next(_ -> {
        if (status != Disposed)
          frame(this);
      });
    }
  }

  override function dispose() {
    var dispose = lifecycle.onDispose;
    if (dispose != null) {
      dispose(this);
    }
    super.dispose();
  }

  function performHydrate(cursor:HydrationCursor) {
    var mount = lifecycle.onMount;
    if (mount != null) {
      mount(this);
    }
    before();
    child = hydrateElementForComponent(cursor, lifecycle.render(this), slot);
    after();
  }

  function performBuild(previousComponent:Null<Component>) {
    var mount = lifecycle.onMount;
    if (previousComponent == null && mount != null) {
      mount(this);
    }
    before();
    child = updateChild(child, lifecycle.render(this), slot);
    after();
  }

  public function visitChildren(visitor:ElementVisitor) {
    if (child != null)
      visitor.visit(child);
  }
}
