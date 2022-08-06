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
  override function dispose() {
    Debug.assert(status != Disposed);

    var scope:Scope = getComponent();
    if (scope != null) scope.doDispose(this);
    
    super.dispose();
  }
}
