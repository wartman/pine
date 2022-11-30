package pine;

import pine.diffing.Key;
import pine.element.*;
import pine.element.proxy.*;
import pine.element.root.*;

abstract class RootComponent extends Component {
  public final child:Null<Component>;

  public function new(props:{
    child:Component,
    ?key:Key
  }) {
    this.child = props.child;
    super(props.key);
  }

  abstract public function createRoot():Root;
  
  function createAncestorManager(element:Element):AncestorManager {
    return new RootAncestorManager(element, createRoot());
  }

  function createChildrenManager(element:Element):ChildrenManager {
    return new ProxyChildrenManager(element, context -> {
      var root:RootComponent = context.getComponent();
      root.child;
    });
  }

  function createSlotManager(element:Element):SlotManager {
    return new ProxySlotManager(element);
  }

  function createObjectManager(element:Element):ObjectManager {
    return new RootObjectManager(element);
  }

  function createLifecycleHooks():Null<LifecycleHooks> {
    return null;
  }
}
