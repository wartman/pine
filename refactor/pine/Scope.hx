package pine;

import pine.core.HasComponentType;
import pine.diffing.Key;
import pine.element.*;
import pine.element.core.*;
import pine.element.proxy.*;
import pine.element.state.*;

/**
  The Scope component allows you to hook into Pine's element
  lifecycle (via the `init` and `dispose` props). In additon,
  you can use it to isolate reactive parts of your component
  instead of forcing the entire component to re-render.
**/
final class Scope extends Component implements HasComponentType {
  final render:(context:Context)->Component;
  final init:Null<(context:Context)->Void>;
  final dispose:Null<(context:Context)->Void>;

  public function new(props:{
    render:(context:Context)->Component,
    ?init:(context:Context)->Void,
    ?dispose:(context:Context)->Void,
    ?key:Key
  }) {
    super(props.key);
    this.init = props.init;
    this.dispose = props.dispose;
    this.render = props.render;
  }
  
  function createAdapterManager(element:Element):AdapterManager {
    return new CoreAdapterManager();
  }

  function createAncestorManager(element:Element):AncestorManager {
    return new CoreAncestorManager(element);
  }

  function createChildrenManager(element:Element):ChildrenManager {
    return new TrackedChildrenManager(element, context -> {
      var scope:Scope = context.getComponent();
      return scope.render(context);
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
      beforeInit: element -> {
        var scope:Scope = element.getComponent();
        if (scope.init != null) scope.init(element);
      },
      onDispose: element -> {
        var scope:Scope = element.getComponent();
        if (scope.dispose != null) scope.dispose(element);
      }
    }
  }
}