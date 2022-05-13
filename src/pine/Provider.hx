package pine;

import pine.ProxyComponent;

@:genericBuild(pine.ProviderBuilder.buildGeneric())
class Provider<T> {}

abstract class ProviderComponent<T> extends ProxyComponent {
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
    if (value != null)
      doDispose(value);
  }

  override function createElement():Element {
    return new ProviderElement<T>(this);
  }
}

class ProviderElement<T> extends ProxyElement {
  override function performBuild(previousComponent:Null<Component>) {
    if (previousComponent != null && previousComponent != component) {
      (cast previousComponent : ProviderComponent<T>).dispose();
    }
    super.performBuild(previousComponent);
  }

  override function dispose() {
    (cast component : ProviderComponent<T>).dispose();
    super.dispose();
  }
}
