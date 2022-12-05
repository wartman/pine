package pine.element.object;

import pine.debug.Debug;
import pine.hydration.Cursor;

using pine.core.OptionTools;

class DirectObjectManager implements ObjectManager {
  final element:ElementOf<ObjectComponent>;

  var object:Null<Dynamic> = null;
  var previousComponent:Null<ObjectComponent> = null;

  public function new(element) {
    this.element = element;
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

    var applicator = findApplicator();

    object = applicator.create(element.component);
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

    var applicator = findApplicator();

    applicator.update(object, element.component, null);
  }

  public function update() {
    Debug.assert(object != null);

    var applicator = findApplicator();

    applicator.update(object, element.component, previousComponent);
    
    previousComponent = element.component;
  }

  public function dispose() {
    if (object != null) {
      var adapter = element.getAdapter().orThrow('No adapter found');
      var component = element.component;
      var applicator = component.getApplicatorFrom(adapter);

      applicator.remove(object, element.slots.get());
    }
    
    object = null;
    previousComponent = null;
  }

  inline function findApplicator() {
    var adapter = element.getAdapter().orThrow('No adapter found');
    var component = element.component;
    return component.getApplicatorFrom(adapter);
  }
}
