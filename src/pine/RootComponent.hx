package pine;

import pine.adapter.Adapter;
import pine.diffing.Key;
import pine.element.*;
import pine.element.root.*;
import pine.element.object.DirectChildrenManager;

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
    return new DirectChildrenManager<RootComponent>(
      element, 
      element -> [ element.component.child ]
    );
  }
  
  override function createAdapterManager(_) {
    return new RootAdapterManager(createAdapter());
  }

  override function createObjectManager(element:Element):ObjectManager {
    return new RootObjectManager(element);
  }
}
