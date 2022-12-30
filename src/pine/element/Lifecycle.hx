package pine.element;

import pine.element.ElementInitMode;
import pine.hydration.Cursor;

typedef Lifecycle<T:Component> = {
  public final ?beforeInit:(element:ElementOf<T>, mode:ElementInitMode)->Void;
  public final ?afterInit:(element:ElementOf<T>, mode:ElementInitMode)->Void;
  public final ?beforeHydrate:(element:ElementOf<T>, cursor:Cursor)->Void;
  public final ?afterHydrate:(element:ElementOf<T>, cursor:Cursor)->Void;
  public final ?beforeUpdate:(element:ElementOf<T>, currentComponent:T, incomingComponent:T)->Void;
  public final ?afterUpdate:(element:ElementOf<T>)->Void;
  public final ?slotUpdated:(element:ElementOf<T>, oldSlot:Null<Slot>, newSlot:Null<Slot>)->Void;
  public final ?beforeDispose:(element:ElementOf<T>)->Void;
  public final ?afterDispose:()->Void;
}
