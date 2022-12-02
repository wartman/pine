package pine;

import haxe.ds.Option;
import pine.element.*;
import pine.element.core.*;
import pine.element.state.*;
import pine.element.proxy.*;

/**
  The AutoComponent is likely the only Component you'll really need
  to use, and it takes care of most of the boilerplate for you.

  @todo: More information, including about what `@:prop` and `@:track` do.
**/
@:allow(pine)
@:autoBuild(pine.AutoComponentBuilder.build())
abstract class AutoComponent extends Component {
  abstract public function render(context:Context):Component;

  abstract function asTrackable():Option<Trackable<Dynamic>>;
  
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

  function createLifecycleHooks() {
    return [];
  }
}
