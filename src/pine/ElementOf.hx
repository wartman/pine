package pine;

import pine.element.ElementStatus;
import pine.element.Lifecycle;

@:forward
abstract ElementOf<T:Component>(Element) 
  from Element to Element 
  to Context 
{
  public var status(get, never):ElementStatus;
  inline function get_status() return this.status;

  public var component(get, never):T;
  inline function get_component():T return this.getComponent();

  public inline function new(element) {
    this = element;
  }

  @:deprecated('Use the component property instead')
  public inline function getComponent():T {
    return this.getComponent();
  }

  public inline function watchLifecycle(hook:Lifecycle<T>) {
    this.lifecycle.add(cast hook);
  }

  public inline function onReady(hook:(element:ElementOf<T>)->Void) {
    watchLifecycle({
      afterInit: hook
    });
  }
}
