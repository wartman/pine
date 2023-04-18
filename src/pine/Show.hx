package pine;

import pine.signal.Signal;
import pine.signal.Graph;

class Show extends ProxyComponent {
  final condition:ReadonlySignal<Bool>;
  final then:()->Component;
  final otherwise:Null<()->Component>;

  public function new(condition, then, ?otherwise) {
    this.condition = condition;
    this.then = then;
    this.otherwise = otherwise;
  }

  function build():Component {
    return new Scope(_ -> if (condition()) {
      untrackValue(then);
    } else if (otherwise != null) {
      untrackValue(otherwise);
    } else {
      new Placeholder();
    });
  }
}
