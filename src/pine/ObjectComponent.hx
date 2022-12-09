package pine;

import pine.element.*;
import pine.element.core.*;
import pine.element.object.*;

using pine.core.OptionTools;

abstract class ObjectComponent extends Component {
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
    var applicator = element.getAdapter().orThrow('No adapter found').getApplicator();
    return new DirectObjectManager(element, applicator);
  }
}
