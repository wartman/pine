package pine;

import pine.diffing.Key;
import pine.element.*;
import pine.element.core.*;
import pine.element.proxy.*;
import pine.element.state.*;

@:build(pine.internal.ComponentUniqueIdBuilder.build())
final class Isolate extends Component {
  public final render:(context:Context)->Component;

  public function new(props:{
    render:(context:Context)->Component,
    ?key:Key
  }) {
    super(props.key);
    this.render = props.render;
  }

  function createAncestorManager(element:Element):AncestorManager {
    return new CoreAncestorManager(element);
  }

  function createChildrenManager(element:Element):ChildrenManager {
    return new TrackedChildrenManager(element, context -> {
      var isolate:Isolate = context.getComponent();
      var component = isolate.render(context);
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
