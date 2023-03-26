package pine;

import pine.diffing.Key;
import pine.state.LazyComputation;

/**
  Runs an effect after a component updates. The effect will only
  be run when its observed signals are invalidated.

  IMPORTANT: Effects are only run when their containing component
  is updated. Use an Observer to react to Signals changing.
**/
class Effect extends AutoComponent {
  public final effect:()->Null<()->Void>;
  public final child:Child;

  function render(context:Context) {
    return new Setup<Effect>({
      target: context,
      setup: element -> {
        var cleanup:Null<()->Void> = null;
        var computed = new LazyComputation(() -> {
          if (cleanup != null) {
            cleanup();
            cleanup = null;
          }
          return element.component.effect();
        });
        inline function resolve() cleanup = computed.get();
        
        element.events.afterInit.add((_, _) -> resolve());
        element.events.afterUpdate.add(_ -> resolve());
        element.events.beforeDispose.add(_ -> {
          computed.dispose();
          if (cleanup != null) cleanup();
        });
      },
      child: child
    });
  }
}
