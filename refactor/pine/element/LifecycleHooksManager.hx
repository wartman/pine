package pine.element;

import pine.hydration.Cursor;

class LifecycleHooksManager {
  final hooks:Array<LifecycleHooks<Dynamic>> = [];

  public function new() {}

  public function add(hook:Null<LifecycleHooks<Dynamic>>) {
    if (hook != null) hooks.push(hook);
  }

  public function beforeInit(element:Element):Void {
    for (hook in hooks) if (hook.beforeInit != null) hook.beforeInit(element);
  }

  public function afterInit(element:Element):Void {
    for (hook in hooks) if (hook.afterInit != null) hook.afterInit(element);
  }

  public function shouldHydrate(element:Element, cursor:Cursor):Bool {
    for (hook in hooks) if (
      hook.shouldHydrate != null
      && !hook.shouldHydrate(element, cursor)
    ) return false;
    return true;
  }

  public function beforeHydrate(element:Element, cursor:Cursor):Void {
    for (hook in hooks) if (hook.beforeHydrate != null) hook.beforeHydrate(element, cursor);
  }

  public function afterHydrate(element:Element, cursor:Cursor):Void {
    for (hook in hooks) if (hook.afterHydrate != null) hook.afterHydrate(element, cursor);
  }

  public function shouldUpdate(element:Element, currentComponent:Component, incomingComponent:Component, isRebuild:Bool):Bool {
    for (hook in hooks) if (
      hook.shouldUpdate != null
      && !hook.shouldUpdate(element, currentComponent, incomingComponent, isRebuild)
    ) return false;
    return true;
  }

  public function beforeUpdate(element:Element, currentComponent:Component, incomingComponent:Component):Void {
    for (hook in hooks) if (hook.beforeUpdate != null) hook.beforeUpdate(element, currentComponent, incomingComponent);
  }

  public function afterUpdate(element:Element):Void {
    for (hook in hooks) if (hook.afterUpdate != null) hook.afterUpdate(element);
  }

  public function onUpdateSlot(element:Element, oldSlot:Null<Slot>, newSlot:Null<Slot>) {
    for (hook in hooks) if (hook.onUpdateSlot != null) hook.onUpdateSlot(element, oldSlot, newSlot);
  }

  public function onDispose(element:Element) {
    for (hook in hooks) if (hook.onDispose != null) hook.onDispose(element);
  }
}
