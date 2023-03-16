package pine.element;

import pine.core.Disposable;
import pine.Component;

using Kit;

class Events<T:Component> implements Disposable {
  public final beforeInit = new Event<ElementOf<T>, ElementInitMode>();
  public final afterInit = new Event<ElementOf<T>, ElementInitMode>();
  public final beforeUpdate = new Event<ElementOf<T>, T, T>();
  public final afterUpdate = new Event<ElementOf<T>>();
  public final slotUpdated = new Event<ElementOf<T>, Null<Slot>, Null<Slot>>();
  public final beforeDispose = new Event<ElementOf<T>>();
  public final afterDispose = new Event<Void>();

  public function new() {}
  
  public function dispose() {
    beforeInit.cancel();
    afterInit.cancel();
    beforeUpdate.cancel();
    afterUpdate.cancel();
    slotUpdated.cancel();
    beforeDispose.cancel();
    afterDispose.cancel();
  }
}
