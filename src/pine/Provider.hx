package pine;

import pine.debug.Debug;
import pine.diffing.Key;
import pine.element.ProxyElementEngine;

@:genericBuild(pine.ProviderBuilder.buildGeneric())
class Provider<T> {}

abstract class ProviderComponent<T> extends Component {
  final create:() -> T;
  final render:(value:T) -> Component;
  final dispose:(value:T) -> Void;
  var value:Null<T> = null;

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

  public function getValue():Null<T> {
    return value;
  }

  public function createElement() {
    var element:ElementOf<ProviderComponent<T>> = new Element(
      this,
      useProxyElementEngine((element:ElementOf<ProviderComponent<T>>) -> {
        var value = element.component.value;
        Debug.assert(value != null);
        return element.component.render(value);
      })
    );

    element.events.beforeInit.add((element, _) -> {
      var component = element.component;
      component.value = component.create();
    });
    element.events.beforeUpdate.add((
      element:ElementOf<ProviderComponent<T>>,
      currentComponent:ProviderComponent<T>,
      incomingComponent:ProviderComponent<T>
    ) -> {
      if (currentComponent == incomingComponent) return;

      var curValue = currentComponent.getValue();
      if (curValue != null) {
        currentComponent.dispose(curValue);
        currentComponent.value = null;
      }
      
      incomingComponent.value = incomingComponent.create();
    });
    element.events.beforeDispose.add(element -> {
      var component = element.component;
      var value = component.getValue();
      if (value != null) {
        component.dispose(value);
        component.value = null;
      }
    });

    return element;
  }
}
