package pine;

import pine.adapter.Adapter;
import pine.diffing.Key;
import pine.element.*;
import pine.element.proxy.*;
import pine.element.root.*;

abstract class RootComponent extends ObjectComponent {
  public final child:Component;

  public function new(props:{
    child:Component,
    ?key:Key
  }) {
    this.child = props.child;
    super(props.key);
  }

  abstract public function getRootObject():Dynamic;

  abstract public function createAdapter():Adapter;

  function createChildrenManager(element:Element):ChildrenManager {
    return new ProxyChildrenManager(element, context -> {
      var root:RootComponent = context.getComponent();
      root.child;
    });
  }
  
  override function createAdapterManager(_) {
    return new RootAdapterManager(createAdapter());
  }

  override function createSlotManager(element:Element):SlotManager {
    return new ProxySlotManager(element);
  }

  override function createObjectManager(element:Element):ObjectManager {
    return new RootObjectManager(element);
  }

  function createLifecycleHooks():Null<LifecycleHooks<Dynamic>> {
    return null;
  }
}
