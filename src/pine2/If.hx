package pine2;

import pine2.signal.Signal;

class If extends ProxyComponent {
  final condition:ReadonlySignal<Bool>;
  final then:()->Component;
  final otherwise:Null<()->Component>;

  public function new(condition, then, ?otherwise) {
    this.condition = condition;
    this.then = then;
    this.otherwise = otherwise;
  }

  function build():Component {
    return if (condition.get()) {
      then();
    } else if (otherwise != null) {
      otherwise();
    } else {
      null;
    }
  }
}
