package pine;

@:allow(pine)
@:autoBuild(pine.ObserverComponentBuilder.build())
abstract class ObserverComponent extends ProxyComponent {
  abstract function getTrackedObject():Dynamic;

  abstract function createTrackedObject():Dynamic;

  abstract function reuseTrackedObject(object:Dynamic):Dynamic;

  override function createElement():Element {
    return new ObserverElement(this);
  }
}
