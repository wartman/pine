package pine;

import pine.element.*;
import pine.element.core.*;
import pine.element.state.*;
import pine.element.proxy.*;

@:autoBuild(pine.internal.ComponentUniqueIdBuilder.build())
@:autoBuild(pine.internal.ComponentTrackedPropertyBuilder.build())
abstract class AutoComponent extends Component {
  abstract public function render(context:Context):Component;
  
  function createAdapterManager(element:Element):AdapterManager {
    return new CoreAdapterManager();
  }

  final function createAncestorManager(element:Element):AncestorManager {
    return new CoreAncestorManager(element);
  }

  final function createChildrenManager(element:Element):ChildrenManager {
    return new TrackedChildrenManager(element, context -> {
      var auto:AutoComponent = context.getComponent();
      return auto.render(context);
    });
  }

  final function createSlotManager(element:Element):SlotManager {
    return new ProxySlotManager(element);
  }

  final function createObjectManager(element:Element):ObjectManager {
    return new ProxyObjectManager(element);
  }

  function createLifecycleHooks():Null<LifecycleHooks> {
    return null;
  }
}
