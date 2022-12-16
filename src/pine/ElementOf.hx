package pine;

import pine.element.ElementStatus;
import pine.element.Lifecycle;

/**
  A simple wrapper over `Element` that makes it more convenient
  to get at the current, properly typed Component.

  Generally speaking, you should always prefer using an `ElementOf`
  over a bare `Element` in type definitions.
**/
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

  public inline function watchLifecycle(lifecycle:Lifecycle<T>) {
    this.events.addLifecycle(cast lifecycle);
  }

  public inline function onReady(listener:(element:ElementOf<T>)->Void) {
    this.events.afterInit.add(cast listener);
  }
}
