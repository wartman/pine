package pine;

import pine.diffing.Key;
import pine.state.LazyComputation;

class Effect extends AutoComponent {
  public final effect:()->Null<()->Void>;
  public final child:Child;

  function render(context:Context) {
    return new Proxy<Effect>({
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
