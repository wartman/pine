package pine.element;

import pine.hydration.Cursor;

typedef LifecycleHooks = {
  public final ?beforeInit:(element:Element)->Void;
  public final ?afterInit:(element:Element)->Void;
  public final ?shouldHydrate:(element:Element, cursor:Cursor)->Bool;
  public final ?beforeHydrate:(element:Element, cursor:Cursor)->Void;
  public final ?afterHydrate:(element:Element, cursor:Cursor)->Void;
  public final ?shouldUpdate:(element:Element, currentComponent:Component, incomingComponent:Component, isRebuild:Bool)->Bool;
  public final ?beforeUpdate:(element:Element, currentComponent:Component, incomingComponent:Component)->Void;
  public final ?afterUpdate:(element:Element)->Void;
}
