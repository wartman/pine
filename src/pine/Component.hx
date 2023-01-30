package pine;

import pine.core.*;
import pine.diffing.*;

abstract class Component {
  public final key:Null<Key>;

  public function new(?key) {
    this.key = key;
  }

  abstract public function getComponentType():UniqueId;

  abstract public function createElement():Element;

  public function shouldBeUpdated(newComponent:Component):Bool {
    return 
      getComponentType() == newComponent.getComponentType() 
      && key == newComponent.key;
  }
}
