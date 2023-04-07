package pine2;

import pine2.signal.Signal;

class Fragment extends Component {
  final children:ReadonlySignal<Array<Component>>;

  public function new(children) {
    this.children = children;
  }

  public function getObject():Dynamic {
    throw new haxe.exceptions.NotImplementedException();
  }

  public function visitChildren(visitor:(child:Component) -> Bool) {}

  public function initialize() {}
}
