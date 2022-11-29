package pine;

@:autoBuild(pine.ImmutableComponentBuilder.build())
abstract class ImmutableComponent extends ProxyComponent {
  @:noCompletion
  abstract public function didPropertiesChange(previousComponent:Component):Bool;

  override function createElement():Element {
    return new ImmutableElement(this);
  }
}

@component(ImmutableComponent)
class ImmutableElement extends ProxyElement {
  override function performBuild(previousComponent:Null<Component>) {
    if (previousComponent != null && !immutableComponent.didPropertiesChange(previousComponent)) {
      return;
    }

    super.performBuild(previousComponent);
  }
}
