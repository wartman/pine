package pine;

import pine.element.LifecycleHooks;

@:forward
abstract ElementOf<T:Component>(Element) from Element to Element to Context {
  public inline function new(element) {
    this = element;
  }

  public inline function getComponent():T {
    return this.getComponent();
  }

  public inline function addHook(hook:LifecycleHooks<T>) {
    this.hooks.add(cast hook);
  }

  public inline function onReady(hook:(element:ElementOf<T>)->Void) {
    addHook({
      afterInit: hook
    });
  }
}
