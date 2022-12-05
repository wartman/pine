package pine;

import pine.adapter.*;
import pine.element.*;
import pine.element.core.*;
import pine.element.object.*;

using pine.core.OptionTools;

abstract class ObjectComponent extends Component {
  public function getApplicatorFrom(adapter:Adapter):ObjectApplicator<Dynamic> {
    return adapter.getApplicator(this);
  }

  function createAncestorManager(element:Element):AncestorManager {
    return new CoreAncestorManager(element);
  }
  
  function createAdapterManager(element:Element):AdapterManager {
    return new CoreAdapterManager();
  }

  function createSlotManager(element):SlotManager {
    return new ObjectSlotManager(element);
  }

  function createObjectManager(element:Element):ObjectManager {
    return new DirectObjectManager(element);
  }
}
