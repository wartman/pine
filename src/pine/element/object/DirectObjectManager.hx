package pine.element.object;

import pine.adapter.ObjectApplicator;
import pine.debug.Debug;
import pine.hydration.Cursor;

using pine.core.OptionTools;

class DirectObjectManager implements ObjectManager {
  final element:ElementOf<ObjectComponent>;
  final applicator:ObjectApplicator<Dynamic>;

  var object:Null<Dynamic> = null;
  var previousComponent:Null<ObjectComponent> = null;

  public function new(element, applicator) {
    this.element = element;
    this.applicator = applicator;

    element.watchLifecycle({
      afterHydrate: (element, cursor) -> {
        if (object != null) cursor.next();
      }
    });
  }

  public function get():Dynamic {
    Debug.assert(object != null);
    return object;
  }

  public function init() {
    Debug.assert(object == null);
    object = applicator.create(element.component);
    applicator.insert(object, element.slots.get(), findAncestorObject);
  }

  public function hydrate(cursor:Cursor) {
    Debug.assert(object == null);
    object = cursor.current();
    Debug.assert(object != null);
    applicator.update(object, element.component, null);
  }

  public function update() {
    Debug.assert(object != null);

    applicator.update(object, element.component, previousComponent);
    
    previousComponent = element.component;
  }

  public function move(oldSlot:Null<Slot>, newSlot:Null<Slot>) {
    if (object != null) {
      applicator.move(object, oldSlot, newSlot, findAncestorObject);
    }
  }

  public function dispose() {
    if (object != null) {
      applicator.remove(object, element.slots.get());
    }
    
    object = null;
    previousComponent = null;
  }

  function findAncestorObject() {
    return element
      .queryAncestors()
      .ofType(ObjectComponent)
      .orThrow('No ancestor object exists')
      .getObject();
  }
}
