package pine;

import pine.signal.Computation;

class Scope extends AutoComponent {
  final childWithContext:(context:Component)->Component;
  final options:{ untrack:Bool };
  
  public function new(child, ?options) {
    this.childWithContext = child;
    this.options = options ?? { untrack: false };
  }

  function build():Component {
    if (options.untrack) return childWithContext(this);
    return new Fragment(new Computation(() -> [ childWithContext(this) ]));
  }
}
