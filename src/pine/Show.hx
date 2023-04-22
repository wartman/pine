package pine;

class Show extends AutoComponent {
  @:observable final condition:Bool;
  final then:()->Component;
  final otherwise:Null<()->Component>;

  public function new(condition, then, ?otherwise) {
    this.condition = condition;
    this.then = then;
    this.otherwise = otherwise;
  }

  function build():Component {
    return new Scope(_ -> if (condition()) {
      then();
    } else if (otherwise != null) {
      otherwise();
    } else {
      new Placeholder();
    });
  }
}
