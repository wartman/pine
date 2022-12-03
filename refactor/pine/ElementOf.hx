package pine;

import pine.element.Lifecycle;

@:forward
abstract ElementOf<T:Component>(Element) from Element to Element to Context {
  public inline function new(element) {
    this = element;
  }

  public inline function getComponent():T {
    return this.getComponent();
  }

  public inline function addLifecycle(hook:Lifecycle<T>) {
    this.lifecycle.add(cast hook);
  }

  public inline function onReady(hook:(element:ElementOf<T>)->Void) {
    addLifecycle({
      afterInit: hook
    });
  }
}
