package pine.element;

import pine.core.Disposable;
import pine.Component;
import pine.core.Event;

class Events<T:Component> implements Disposable {
  public final beforeInit:Event2<ElementOf<T>, ElementInitMode> = new Event2();
  public final afterInit:Event2<ElementOf<T>, ElementInitMode> = new Event2();
  public final beforeUpdate:Event3<ElementOf<T>, T, T> = new Event3();
  public final afterUpdate:Event1<ElementOf<T>> = new Event1();
  public final slotUpdated:Event3<ElementOf<T>, Null<Slot>, Null<Slot>> = new Event3();
  public final beforeDispose:Event1<ElementOf<T>> = new Event1();
  public final afterDispose:Event0 = new Event0();

  public function new() {}
  
  public function dispose() {
    beforeInit.clear();
    afterInit.clear();
    beforeUpdate.clear();
    afterUpdate.clear();
    slotUpdated.clear();
    beforeDispose.clear();
    afterDispose.clear();
  }
}
