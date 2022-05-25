package pine;

@:autoBuild(pine.TrackedComponentBuilder.build())
abstract class TrackedComponent extends ProxyComponent {
  override function createElement():Element {
    return new ObserverElement(this);
  }
}
