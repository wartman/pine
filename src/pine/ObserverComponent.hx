package pine;

class ObserverComponent extends ProxyComponent {
  static final type = new UniqueId();

  final doRender:(context:Context) -> Component;

  public function new(props:{
    render:(context:Context) -> Component,
    ?key:Key
  }) {
    super(props.key);
    this.doRender = props.render;
  }

  public function render(context:Context) {
    return doRender(context);
  }

  public function getComponentType():UniqueId {
    return type;
  }

  override function createElement():Element {
    return new ObserverElement(this);
  }
}
