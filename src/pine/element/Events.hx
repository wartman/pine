package pine.element;

import pine.Component;
import pine.core.Event;

// @todo: we should dispose this thing
class Events<T:Component> {
  public final beforeInit:Event2<ElementOf<T>, ElementInitMode> = new Event2();
  public final afterInit:Event2<ElementOf<T>, ElementInitMode> = new Event2();
  public final beforeUpdate:Event3<ElementOf<T>, T, T> = new Event3();
  public final afterUpdate:Event1<ElementOf<T>> = new Event1();
  public final slotUpdated:Event3<ElementOf<T>, Null<Slot>, Null<Slot>> = new Event3();
  public final beforeDispose:Event1<ElementOf<T>> = new Event1();
  public final afterDispose:Event0 = new Event0();
  public final beforeRevalidatedRender:Event0 = new Event0();

  public function new() {}

  public function addLifecycle(lifecycle:Lifecycle<T>) {
    if (lifecycle.beforeInit != null) beforeInit.add(lifecycle.beforeInit);
    if (lifecycle.afterInit != null) afterInit.add(lifecycle.afterInit);
    if (lifecycle.beforeHydrate != null) beforeInit.add((element, mode) -> switch mode {
      case Hydrating(cursor): lifecycle.beforeHydrate(element, cursor);
      default:
    });
    if (lifecycle.afterHydrate != null) afterInit.add((element, mode) -> switch mode {
      case Hydrating(cursor): lifecycle.afterHydrate(element, cursor);
      default:
    });
    if (lifecycle.beforeUpdate != null) beforeUpdate.add(lifecycle.beforeUpdate);
    if (lifecycle.afterUpdate != null) afterUpdate.add(lifecycle.afterUpdate);
    if (lifecycle.slotUpdated != null) slotUpdated.add(lifecycle.slotUpdated);
    if (lifecycle.beforeDispose != null) beforeDispose.add(lifecycle.beforeDispose);
    if (lifecycle.afterDispose != null) afterDispose.add(lifecycle.afterDispose);
  }
}
