package pine.element;

import pine.Component;
import pine.internal.Event;
import pine.hydration.Cursor;

class EventManager<T:Component> {
  public final beforeInit:Event1<ElementOf<T>> = new Event1();
  public final afterInit:Event1<ElementOf<T>> = new Event1();
  public final beforeHydrate:Event2<ElementOf<T>, Cursor> = new Event2();
  public final afterHydrate:Event2<ElementOf<T>, Cursor> = new Event2();
  public final beforeUpdate:Event3<ElementOf<T>, T, T> = new Event3();
  public final afterUpdate:Event1<ElementOf<T>> = new Event1();
  public final slotUpdated:Event3<ElementOf<T>, Null<Slot>, Null<Slot>> = new Event3();
  public final beforeDispose:Event1<ElementOf<T>> = new Event1();
  public final afterDispose:Event0 = new Event0();

  public function new() {}

  public function addLifecycle(lifecycle:Lifecycle<T>) {
    if (lifecycle.beforeInit != null) beforeInit.add(lifecycle.beforeInit);
    if (lifecycle.afterInit != null) afterInit.add(lifecycle.afterInit);
    if (lifecycle.beforeHydrate != null) beforeHydrate.add(lifecycle.beforeHydrate);
    if (lifecycle.afterHydrate != null) afterHydrate.add(lifecycle.afterHydrate);
    if (lifecycle.beforeUpdate != null) beforeUpdate.add(lifecycle.beforeUpdate);
    if (lifecycle.afterUpdate != null) afterUpdate.add(lifecycle.afterUpdate);
    if (lifecycle.slotUpdated != null) slotUpdated.add(lifecycle.slotUpdated);
    if (lifecycle.beforeDispose != null) beforeDispose.add(lifecycle.beforeDispose);
    if (lifecycle.afterDispose != null) afterDispose.add(lifecycle.afterDispose);
  }
}
