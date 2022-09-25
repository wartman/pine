package pine;

@:genericBuild(pine.ProviderBuilder.buildGeneric())
class Provider<T> {}

abstract class ProviderComponent<T> extends Component {
  public final create:() -> T;
  public final doRender:(value:T) -> Component;
  public final doDispose:(value:T) -> Void;

  var value:Null<T> = null;

  public function new(props:{
    create:() -> T,
    render:(value:T) -> Component,
    dispose:(value:T) -> Void,
    ?key:Key
  }) {
    super(props.key);
    create = props.create;
    doRender = props.render;
    doDispose = props.dispose;
  }

  public function render(context:Context):Component {
    if (value == null) {
      value = create();
    }
    return doRender(value);
  }

  public function dispose() {
    if (value != null) doDispose(value);
  }

  function createElement():Element {
    return new ProviderElement<T>(this);
  }
}

class ProviderElement<T> extends Element {
  final child:SingleChild;

  var provider(get, never):ProviderComponent<T>;
  function get_provider():ProviderComponent<T> return getComponent();
  
  public function new(component:ProviderComponent<T>) {
    super(component);
    child = new SingleChild(() -> provider.render(this), new DefaultElementFactory(this));
  }

  function performHydrate(cursor:HydrationCursor) {
    child.hydrate(cursor, slot);
  }

  function performBuild(previousComponent:Null<Component>) {
    if (previousComponent != null && previousComponent != component) {
      (cast previousComponent : ProviderComponent<T>).dispose();
    }
    child.update(previousComponent, slot);
  }

  function performUpdateSlot(?slot:Slot) {
    child.visit(child -> child.updateSlot(slot));
  }

  public function visitChildren(visitor:ElementVisitor) {
    child.visit(visitor);
  }

  function performDispose() {
    provider.dispose();
    child.dispose();
  }
}
