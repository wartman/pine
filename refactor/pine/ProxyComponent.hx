package pine;

import pine.element.*;
import pine.element.core.CoreAncestorManager;
import pine.element.proxy.*;

abstract class ProxyComponent extends Component {
  abstract public function render(context:Context):Component;

  function createAncestorManager(element:Element):AncestorManager {
    return new CoreAncestorManager(element);
  }

  function createChildrenManager(element:Element):ChildrenManager {
    return new ProxyChildrenManager(element, element -> {
      var proxy:ProxyComponent = element.getComponent();
      var component = proxy.render(element);
      if (component == null) return new Fragment({ children: [] });
      return component;
    });
  }

  function createSlotManager(element:Element):SlotManager {
    return new ProxySlotManager(element);
  }

  function createObjectManager(element:Element):ObjectManager {
    return new ProxyObjectManager(element);
  }

  function createLifecycleHooks():Null<LifecycleHooks> {
    return null;
  }
}
