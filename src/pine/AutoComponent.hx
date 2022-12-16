package pine;

import haxe.ds.Option;
import pine.element.*;
import pine.element.core.*;
import pine.element.state.*;
import pine.element.proxy.*;

/**
  The AutoComponent is likely the only Component you'll need
  to use. It automatically creates a constructor for you and sets up
  the correct Managers to make the component reactive.

  When authoring a component, keep in mind that *all* fields 
  will be added to the constructor. `final` fields are simply
  initialized there, but non-final fields are converted via a macro
  into properties backed by `pine.state.Signal`. If you don't want a field
  to be processed, mark it with `@:skip`.
**/
@:allow(pine)
@:autoBuild(pine.AutoComponentBuilder.build())
abstract class AutoComponent extends Component {
  abstract public function render(context:Context):Component;

  @:noCompletion
  abstract function asTrackable():Option<Trackable<Dynamic>>;
  
  function createAdapterManager(element:Element):AdapterManager {
    return new CoreAdapterManager();
  }

  final function createAncestorManager(element:Element):AncestorManager {
    return new CoreAncestorManager(element);
  }

  final function createChildrenManager(element:Element):ChildrenManager {
    return new TrackedChildrenManager<AutoComponent>(
      element, 
      element -> element.component.render(element)
    );
  }

  final function createSlotManager(element:Element):SlotManager {
    return new ProxySlotManager(element);
  }

  final function createObjectManager(element:Element):ObjectManager {
    return new ProxyObjectManager(element);
  }
}
