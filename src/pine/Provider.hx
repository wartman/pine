package pine;

import pine.ProxyComponent;

using Lambda;
using pine.Cast;

@:genericBuild(pine.ProviderBuilder.buildGeneric())
class Provider<T> {}

abstract class ProviderComponent<T> extends Component {
  public final create:() -> T;
  public final render:(value:T) -> Component;
  public final dispose:(value:T) -> Void;

  public function new(props:{
    create:() -> T,
    render:(value:T) -> Component,
    dispose:(value:T) -> Void,
    ?key:Key
  }) {
    super(props.key);
    create = props.create;
    render = props.render;
    dispose = props.dispose;
  }

  public function createElement():Element {
    return new ProviderElement<T>(this);
  }
}

@component(ProviderComponent(T))
class ProviderElement<T> extends Element {
  var value:Null<T> = null;
  var child:Null<Element> = null;

  public function getValueFor(context:Context) {
    return value;
  }
  
  function render() {
    if (value == null) {
      value = providerComponent.create();
    }
    var comp = providerComponent.render(value);
    if (comp == null) comp = new Fragment({ children: [] });
    return comp;
  }

  function performHydrate(cursor:HydrationCursor) {
    child = hydrateElementForComponent(cursor, render(), slot);
  }

  function performBuild(previousComponent:Null<Component>) {
    if (previousComponent != null && previousComponent != component) {
      if (value != null) {
        providerComponent.dispose(value);
        value = null;
      }
    }

    child = updateChild(child, render(), slot);
  }

  function performDispose() {
    // for (child in dependencies) dependencies.remove(child);
    if (value != null) providerComponent.dispose(value);
    value = null;
  }

  public function visitChildren(visitor:ElementVisitor) {
    if (child != null) visitor.visit(child);
  }
}
