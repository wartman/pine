package pine.element.object;

import pine.element.core.CoreSlotManager;

using pine.core.OptionTools;

class ObjectSlotManager extends CoreSlotManager {
  override function update(newSlot:Slot) {
    var oldSlot = this.slot;
    super.update(newSlot);
    
    var object = element.getObject();
    var applicator = findApplicator();

    applicator.move(object, oldSlot, newSlot, () -> element
      .queryAncestors()
      .ofType(ObjectComponent)
      .orThrow('No ancestor object exists')
      .getObject()
    );
  }

  inline function findApplicator() {
    var adapter = element.getAdapter().orThrow('No adapter found');
    var component:ObjectComponent = element.getComponent();
    return component.getApplicatorFrom(adapter);
  }
}
