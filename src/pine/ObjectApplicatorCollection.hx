package pine;

import pine.UniqueId;
import pine.ObjectApplicator;

using Type;

@:forward(get)
abstract ObjectApplicatorCollection(Map<UniqueId, ObjectApplicator<Dynamic>>) from Map<UniqueId, ObjectApplicator<Dynamic>> {
  public function new(applicators) {
    this = applicators;
  }

  public function getForComponent<T:ObjectComponent>(component:T):ObjectApplicator<T> {
    var applicator = this.get(component.getApplicatorType());
    if (applicator == null) {
      Debug.error('No applicator found for the component');
    }
    return cast applicator;
  }
}
