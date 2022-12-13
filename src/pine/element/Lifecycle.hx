package pine.element;

import pine.hydration.Cursor;

typedef Lifecycle<T:Component> = {
  public final ?beforeInit:(element:ElementOf<T>)->Void;
  public final ?afterInit:(element:ElementOf<T>)->Void;
  public final ?onUpdateSlot:(element:ElementOf<T>, oldSlot:Null<Slot>, newSlot:Null<Slot>)->Void;
  public final ?shouldHydrate:(element:ElementOf<T>, cursor:Cursor)->Bool;
  public final ?beforeHydrate:(element:ElementOf<T>, cursor:Cursor)->Void;
  public final ?afterHydrate:(element:ElementOf<T>, cursor:Cursor)->Void;
  public final ?shouldUpdate:(element:ElementOf<T>, currentComponent:T, incomingComponent:T, isRebuild:Bool)->Bool;
  public final ?beforeUpdate:(element:ElementOf<T>, currentComponent:T, incomingComponent:T)->Void;
  public final ?afterUpdate:(element:ElementOf<T>)->Void;
  public final ?beforeDispose:(element:ElementOf<T>)->Void;
  public final ?afterDispose:()->Void;
}
