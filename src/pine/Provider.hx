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
  // final dependencies:List<Element> = new List();
  var value:Null<T> = null;
  var child:Null<Element> = null;

  public function getValueFor(context:Context) {
    // var el = context.as(Element);
    // if (!dependencies.has(el)) {
    //   dependencies.add(el);
    // }
    return value;
  }
  
  function render() {
    if (value == null) {
      value = providerComponent.create();
    }
    var comp = providerComponent.render(value);
    // Note: We always need an object leaf at the end of our component
    // tree, so we have to handle cases where the user returns `null`. 
    // We don't use `Adapter.from(this).createPlaceholder()` as there
    // is some extra logic needed to ensure it works with hydration,
    // which the Fragment takes care of.
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

      // @todo: This is a hack. We need to figure out how to 
      // make dependencies actually work. For now, we force a complete
      // re-render if the provider value changes. This is obviously
      // extremely innefficent, but it solves the edge cases where we
      // need it to.
      child = updateChild(child, new Fragment({ children: [] }), slot);
      
      // updateDependents();
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

  // function updateDependents() {
  //   for (child in dependencies) switch child.status {
  //     case Disposing | Disposed: 
  //       dependencies.remove(child);
  //     default: 
  //       child.invalidate();
  //   }
  // }
}
