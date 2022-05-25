package pine;

@:autoBuild(pine.ObserverComponentBuilder.build())
abstract class ObserverComponent extends ProxyComponent {
  override function createElement():Element {
    return new ObserverElement(this);
  }
}
