package pine;

import pine.element.Events;
import pine.element.ElementStatus;

typedef Cleanup = Null<()->Void>; 

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
  @:from public inline static function ofContext<T:Component>(context:Context):ElementOf<T> {
    return new ElementOf(cast context);
  }

  public var status(get, never):ElementStatus;
  inline function get_status() return this.status;

  public var component(get, never):T;
  inline function get_component():T return this.getComponent();

  public var events(get, never):Events<T>;
  inline function get_events():Events<T> return cast this.events;

  public inline function new(element) {
    this = element;
  }

  public function onInit(listener:()->Cleanup) {
    var cleanup:Cleanup = null;
    this.events.afterInit.add((_, _) -> {
      cleanup = listener();
    });
    this.events.beforeDispose.add(_ -> {
      if (cleanup != null) {
        cleanup();
        cleanup = null;
      }
    });
  }

  public function onUpdate(listener:()->Cleanup, ?options:{
    ?skipInit:Bool,
    ?onlyCleanupWhenDisposing:Bool
  }) {
    var cleanup:Cleanup = null;
    var alwaysCleanup = options == null || options.onlyCleanupWhenDisposing != true;
    if (options == null || options.skipInit != true) this.events.afterInit.add((_, _) -> {
      cleanup = listener();
    });
    this.events.afterUpdate.add((_) -> {
      if (cleanup != null && alwaysCleanup) cleanup();
      cleanup = listener();
    });
    this.events.beforeDispose.add(_ -> {
      if (cleanup != null) {
        cleanup();
        cleanup = null;
      }
    });
  }

  public function onDispose(dispose:()->Void) {
    this.events.beforeDispose.add(_ -> dispose());
  }
}
