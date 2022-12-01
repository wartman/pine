package pine;

import pine.element.core.*;
import pine.element.proxy.*;
import pine.diffing.Key;
import pine.element.*;

@:genericBuild(pine.internal.ProviderBuilder.buildGeneric())
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

	function createLifecycleHooks():Null<LifecycleHooks> {
    return {
      beforeInit: (element:Element) -> {
        var component:ProviderComponent<T> = element.getComponent();
        component.value = component.create();
      },

      beforeUpdate: (
        element:Element,
        currentComponent:Component,
        incomingComponent:Component
      ) -> {
        var cur:ProviderComponent<T> = cast currentComponent;
        var inc:ProviderComponent<T> = cast incomingComponent;
        var curValue = cur.getValue();

        if (curValue != null) {
          cur.dispose(curValue);
          cur.value = null;
        }

        inc.value = inc.create();
      },

      onDispose: (element:Element) -> {
        var component:ProviderComponent<T> = element.getComponent();
        var value = component.getValue();
        if (value != null) {
          component.dispose(value);
          component.value = null;
        }
      }
    };
	}
}
