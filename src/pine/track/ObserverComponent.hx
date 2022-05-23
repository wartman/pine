package pine.track;

class ObserverComponent extends Component {
  static final type = new UniqueId();

  public final render:(context:Context) -> Component;

  public function new(props:{
    render:(context:Context) -> Component,
    ?key:Key
  }) {
    super(props.key);
    this.render = props.render;
  }

  public function getComponentType():UniqueId {
    return type;
  }

  public function createElement():Element {
    return new ObserverElement(this);
  }
}

class ObserverElement extends Element {
  var observer:Null<Observer> = null;
  var result:Null<Component> = null;
  var observerComponent(get, never):ObserverComponent;
  var child:Null<Element> = null;

  public inline function get_observerComponent():ObserverComponent {
    return cast component;
  }

  function performHydrate(cursor:HydrationCursor) {
    setupObserver();

    if (result == null) {
      result = observerComponent.render(this);
    }

    child = hydrateElementForComponent(cursor, result, slot);
  }

  function performBuild(previousComponent:Null<Component>) {
    if (previousComponent == null || observer == null) {
      setupObserver();
    }

    if (result == null) {
      result = observerComponent.render(this);
    }

    child = updateChild(child, result, slot);
  }

  public function visitChildren(visitor:ElementVisitor) {
    if (child != null) {
      visitor.visit(child);
    }
  }

  function setupObserver() {
    var first = true;
    observer = new Observer(() -> {
      result = observerComponent.render(this);
      if (!first) invalidate();
    });
  }

  override function dispose() {
    super.dispose();
    observer.dispose();
  }
}
