package pine;

abstract class ProxyComponent extends Component {
  public function init(context:InitContext) {
    // noop
  }

  abstract public function render(context:Context):Component;

  public function createElement():Element {
    return new ProxyElement(this);
  }
}
