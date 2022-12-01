package pine;

import pine.adapter.*;
import pine.debug.Debug;
import pine.element.*;
import pine.element.core.*;
import pine.hydration.Cursor;

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
    return new RealObjectManager(element);
  }
}

class RealObjectManager implements ObjectManager {
  final element:ElementOf<ObjectComponent>;

  var object:Null<Dynamic> = null;

  public function new(element) {
    this.element = element;
  }

  public function get():Dynamic {
    Debug.assert(object != null);
    return object;
  }

  public function init() {
    Debug.assert(object == null);

    var adapter = element.getAdapter().orThrow('No adapter found');
    var component = element.getComponent();
    var applicator = component.getApplicatorFrom(adapter);

    object = applicator.create(component);
    applicator.insert(object, element.slots.get(), () -> element
      .queryAncestors()
      .ofType(ObjectComponent)
      .orThrow('No ancestor object exists')
      .getObject()
    );
  }

  public function hydrate(cursor:Cursor) {
    Debug.assert(object == null);
    object = cursor.current();
    Debug.assert(object != null);

    var component:ObjectComponent = element.getComponent();
    var applicator = Adapter.from(element).getApplicator(component);

    applicator.update(object, component);
  }

  public function update() {
    Debug.assert(object != null);

    var component:ObjectComponent = element.getComponent();
    var applicator = Adapter.from(element).getApplicator(component);

    applicator.update(object, component);
  }

  public function dispose() {
    if (object != null) {
      var component:ObjectComponent = element.getComponent();
      var applicator = Adapter.from(element).getApplicator(component);
      applicator.remove(object, element.slots.get());
      object = null;
    }
  }
}

class ObjectSlotManager extends CoreSlotManager {
  override function update(newSlot:Slot) {
    var oldSlot = this.slot;
    super.update(newSlot);
    
    var object = element.getObject();
    var applicator = Adapter.from(element).getApplicator(element.getComponent());

    applicator.move(object, oldSlot, newSlot, () -> element
      .queryAncestors()
      .ofType(ObjectComponent)
      .orThrow('No ancestor object exists')
      .getObject()
    );
  }
}
