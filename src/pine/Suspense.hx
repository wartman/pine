package pine;

import pine.signal.Scheduler;
import pine.signal.Resource;

using Kit;

// @todo: This is just a very simple first step.
// @todo: We need to add the ability to propagate (or not) up to
// parent Suspenses.
@:allow(pine.signal.Resource)
class Suspense extends Component {
  public static function from(context:View) {
    return context.get(Suspense)
      .toMaybe()
      .orThrow('No Suspense found');
  }

  @:attribute final onSuspended:()->Void = null;
  @:attribute final onComplete:()->Void = null;
  @:attribute final onFailed:()->Void = null;
  @:children @:attribute final children:Children;

  var scheduled:Bool = false;
  final resources:Array<ResourceObject<Any, Any>> = [];

  function markResourceAsSuspended(resource:ResourceObject<Any, Any>) {
    if (resources.contains(resource)) return;
    var isFirstSuspense = resources.length == 0;
    resources.push(resource);
    if (isFirstSuspense && onSuspended != null) onSuspended(); 
  }

  function markResourceAsCompleted(resource:ResourceObject<Any, Any>) {
    if (!resources.contains(resource)) return;
    resources.remove(resource);
    // This is probably too fragile:
    if (resources.length == 0 && onComplete != null && !scheduled) {
      scheduled = true;
      Scheduler.current().schedule(() -> {
        scheduled = false;
        if (resources.length == 0) onComplete();
      });
    }
  }

  function markResourceAsFailed(resource:ResourceObject<Any, Any>) {
    if (!resources.contains(resource)) return;
    resources.remove(resource);
    if (resources.length == 0 && onFailed != null) onFailed();
  }

  function render() {
    return Provider.provide(this).children(children);
  }
}
