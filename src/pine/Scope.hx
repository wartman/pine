package pine;

import pine.ProxyComponent;

@:allow(pine.ScopeElement)
class Scope extends ProxyComponent {
  static final type = new UniqueId();

  final doInit:Null<(context:InitContext)->Void>;
  final doRender:(context:Context) -> Component;
  final doDispose:Null<(context:Context) -> Void>;

  public function new(props:{
    render:(context:Context) -> Component,
    ?init:(context:InitContext) -> Void,
    ?dispose:(context:Context) -> Void,
    ?key:Key
  }) {
    super(props.key);
    this.doInit = props.init;
    this.doRender = props.render;
    this.doDispose = props.dispose;
  }

  override function init(context:InitContext) {
    if (doInit != null) doInit(context);
  }

  public function getComponentType():UniqueId {
    return type;
  }

  public function render(context:Context):Component {
    return doRender(context);
  }

  override function createElement():Element {
    return new ScopeElement(this);
  }
}

private class ScopeElement extends ProxyElement {
  override function performDispose() {
    var scope:Scope = getComponent();
    if (scope != null && scope.doDispose != null) scope.doDispose(this);
    super.performDispose();
  }
}
