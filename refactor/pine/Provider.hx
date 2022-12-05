package pine;

import pine.element.core.*;
import pine.element.proxy.*;
import pine.diffing.Key;
import pine.element.*;

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

  function createAdapterManager(element:Element):AdapterManager {
    return new CoreAdapterManager();
  }

  function createAncestorManager(element:Element):AncestorManager {
    return new CoreAncestorManager(element);
  }

  function createChildrenManager(element:Element):ChildrenManager {
    return new ProxyChildrenManager(element, context -> {
      var component:ProviderComponent<T> = context.getComponent();
      // Our lifecycle hooks *should* ensure our value is ready
      // by now, so...
      var value:T = cast component.getValue();
      return component.render(value);
    });
  }

  function createSlotManager(element:Element):SlotManager {
    return new ProxySlotManager(element);
  }

  function createObjectManager(element:Element):ObjectManager {
    return new ProxyObjectManager(element);
  }

  override function createHooks():HookCollection<Dynamic> {
    return new HookCollection([
      (element:ElementOf<ProviderComponent<T>>) -> {
        element.watchLifecycle({
          beforeInit: element -> {
            var component = element.component;
            component.value = component.create();
          },
    
          beforeUpdate: (
            element:ElementOf<ProviderComponent<T>>,
            currentComponent:ProviderComponent<T>,
            incomingComponent:ProviderComponent<T>
          ) -> {
            var curValue = currentComponent.getValue();
            if (curValue != null) {
              currentComponent.dispose(curValue);
              currentComponent.value = null;
            }
            incomingComponent.value = incomingComponent.create();
          },
    
          onDispose: element -> {
            var component = element.component;
            var value = component.getValue();
            if (value != null) {
              component.dispose(value);
              component.value = null;
            }
          }
        });
      }
    ]);
  }
}
