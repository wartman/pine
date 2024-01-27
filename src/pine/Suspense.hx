package pine;

import pine.signal.Resource;

// @todo: This is just a very simple first step.
@:allow(pine.signal.Resource)
class Suspense extends Component {
  @:attribute final onSuspended:()->Void = null;
  @:attribute final onComplete:()->Void = null;
  @:attribute final onFailed:()->Void = null;
  @:children @:attribute final children:Children;

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
    if (resources.length == 0 && onComplete != null) onComplete();
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
