package pine;

@:allow(pine)
@:autoBuild(pine.ObserverComponentBuilder.build())
abstract class ObserverComponent extends Component {
  abstract function getTrackedObject():Dynamic;

  abstract function createTrackedObject():Dynamic;

  abstract function reuseTrackedObject(object:Dynamic):Dynamic;

  public function init(context:InitContext) {}

  abstract public function render(context:Context):Component;

  public function createElement():Element {
    return new ObserverElement(this);
  }
}
