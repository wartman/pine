package pine;

typedef ObservableComponentRenderer<T> = (value:T, update:(value:T) -> Void) -> Component;

class ObservableComponent<T> extends Component {
  static final type = new UniqueId();

  public final observable:Observable<T>;

  final doRender:ObservableComponentRenderer<T>;

  public function new(props:{
    observable:Observable<T>,
    render:ObservableComponentRenderer<T>,
    ?key:Key
  }) {
    super(props.key);
    doRender = props.render;
    observable = props.observable;
  }

  public function getComponentType():UniqueId {
    return type;
  }

  public function observe() {
    return observable;
  }

  public function render() {
    return doRender(observable.read(), observable.update);
  }

  override function shouldBeUpdated(newComponent:Component):Bool {
    if (!super.shouldBeUpdated(newComponent)) {
      return false;
    }
    var other:ObservableComponent<Dynamic> = cast newComponent;
    return observable.read() != other.observable.read();
  }

  public function createElement():Element {
    return new ObservableElement(this);
  }
}

class ObservableElement<T> extends Element {
  var link:Null<Disposable> = null;
  var childElement:Null<Element> = null;
  var observableComponent(get, never):ObservableComponent<T>;

  inline function get_observableComponent():ObservableComponent<T> {
    return cast component;
  }

  public function visitChildren(visitor:ElementVisitor) {
    if (childElement != null) {
      visitor.visit(childElement);
    }
  }

  function performHydrate(cursor:HydrationCursor) {
    var obs:ObservableComponent<T> = cast component;
    track();
    childElement = hydrateElementForComponent(cursor, obs.render(), slot);
  }

  public function performBuild(previousComponent:Null<Component>) {
    if (component == previousComponent) {
      performBuildChild();
    } else {
      track();
      performBuildChild();
    }
  }

  function track() {
    cleanupLink();
    link = observableComponent.observe().bindNext(_ -> invalidate());
  }

  inline function cleanupLink() {
    if (link != null) link.dispose();
    link = null;
  }

  function performBuildChild() {
    childElement = updateChild(childElement, observableComponent.render(), slot);
  }

  override function dispose() {
    cleanupLink();
    super.dispose();
  }
}
