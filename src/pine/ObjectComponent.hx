package pine;

import pine.adapter.*;
import pine.element.*;
import pine.element.core.*;
import pine.element.object.*;

using pine.core.OptionTools;

abstract class ObjectComponent extends Component {
  abstract public function getObjectType():ObjectType;

  abstract public function getObjectData():Dynamic;

  function createAncestorManager(element:Element):AncestorManager {
    return new CoreAncestorManager(element);
  }
  
  function createAdapterManager(element:Element):AdapterManager {
    return new CoreAdapterManager();
  }

  function createSlotManager(element:Element):SlotManager {
    return new CoreSlotManager(element);
  }

  function createObjectManager(element:Element):ObjectManager {
    var applicator = element
      .getAdapter()
      .orThrow('No Adapter found')
      .getObjectApplicator(getObjectType());
    return new DirectObjectManager(element, applicator);
  }
}
