package pine;

import pine.core.Disposable;

private final hookRegistry:Map<Context, Hook<Dynamic>> = [];

// @todo: Instead of having a hookRegistry, we might just have a
// hook instance on our Element. On the other hand, I think this works fine
// and will only get used if needed.
@:allow(pine)
class Hook<T:Component> implements Disposable {
  public static function from<T:Component>(element:ElementOf<T>):Hook<T> {
    if (!hookRegistry.exists(element)) {
      var hook = new Hook(element);
      hookRegistry.set(element, hook);
    }
    return cast hookRegistry.get(element);
  }

  final element:ElementOf<T>;
  var states:Array<Null<Dynamic>> = [];
  var cleanups:Array<Null<(value:Null<Dynamic>)->Void>> = [];
  var index = 0;

  public function new(element) {
    this.element = element;
    
    var events = element.events;

    events.beforeDispose.add(_ -> {
      hookRegistry.remove(element);
      dispose();
    });
    events.beforeRevalidatedRender.add(() -> index = 0);
    events.beforeInit.add((element, _) -> reset(null, null));
    events.beforeUpdate.add((element, currentComponent, incomingComponent) -> reset(currentComponent, incomingComponent));
  }

  function useIndex() {
    var i = index++;
    if (states.length == i) {
      states[i] = null;
      cleanups[i] = null;
    }
    return i;
  }

  function getState(index:Int):Null<Dynamic> {
    return states[index];
  }

  function setState<R>(index:Int, data:R, ?cleanup:(value:R)->Void) {
    states[index] = data;
    cleanups[index] = cleanup;
  }

  function getElement():ElementOf<T> {
    return element;
  }

	public function dispose() {
    cleanupState();
  }

  function reset(currentComponent:Null<T>, incomingComponent:Null<T>) {
    if (index == 0) return;

    index = 0;
    // @todo: This shouldn't always happen! We should be able to configure this.
    if (currentComponent != null && currentComponent != incomingComponent) {
      cleanupState();
    }
  }

  function cleanupState() {
    var cleanupMethods = cleanups.copy();
    var cleanupState = states.copy();
    
    states = [];
    cleanups = [];

    for (index => state in cleanupState) {
      var cleanup = cleanupMethods[index];
      if (cleanup != null) cleanup(state);
    }
  }
}
