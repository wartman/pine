package pine;

import pine.adaptor.*;
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
  
  function createAdaptorManager(element:Element):AdaptorManager {
    return new CoreAdaptorManager();
  }

  function createSlotManager(element:Element):SlotManager {
    return new CoreSlotManager(element);
  }

  function createObjectManager(element:Element):ObjectManager {
    var applicator = element
      .getAdaptor()
      .orThrow('No Adaptor found')
      .getObjectApplicator(getObjectType());
    return new DirectObjectManager(element, applicator);
  }
}
