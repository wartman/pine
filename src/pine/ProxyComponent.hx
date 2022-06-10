package pine;

abstract class ProxyComponent extends Component {
  public function init(context:InitContext) {}

  abstract public function render(context:Context):Component;

  public function createElement():Element {
    return new ProxyElement(this);
  }
}
