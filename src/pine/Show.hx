package pine;

class Show extends AutoComponent {
  @:observable final condition:Bool;
  final then:()->Child;
  final otherwise:Null<()->Child>;

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
