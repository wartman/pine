package pine;

import pine.ProxyComponent;

@:allow(pine.ScopeElement)
class Scope extends ProxyComponent {
  static final type = new UniqueId();

  final doRender:(context:Context) -> Component;
  final doDispose:Null<(context:Context) -> Void>;

  public function new(props:{
    render:(context:Context) -> Component,
    ?dispose:(context:Context) -> Void,
    ?key:Key
  }) {
    super(props.key);
    this.doRender = props.render;
    this.doDispose = props.dispose;
  }

  override function init(context:InitContext) {
    if (doDispose != null) {
      Cleanup.on(context).add(() -> doDispose(context));
    }
  }

  public function getComponentType():UniqueId {
    return type;
  }

  public function render(context:Context):Component {
    return doRender(context);
  }
}
