package pine;

import pine.internal.*;
import pine.diffing.*;
import pine.element.*;

@:allow(pine)
abstract class Component {
  public final key:Null<Key>;

  public function new(?key) {
    this.key = key;
  }

  abstract public function getComponentType():UniqueId;

  public function createElement():Element {
    return new Element(this);
  }

  public function shouldBeUpdated(newComponent:Component):Bool {
    return 
      getComponentType() == newComponent.getComponentType() 
      && key == newComponent.key;
  }

  abstract function createAdapterManager(element:Element):AdapterManager;

  abstract function createAncestorManager(element:Element):AncestorManager;

  abstract function createChildrenManager(element:Element):ChildrenManager;

  abstract function createSlotManager(element:Element):SlotManager;

  abstract function createObjectManager(element:Element):ObjectManager;

  abstract function createLifecycleHooks():Null<LifecycleHooks>;
}
