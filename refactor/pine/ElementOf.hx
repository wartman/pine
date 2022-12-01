package pine;

@:forward
abstract ElementOf<T:Component>(Element) from Element to Element to Context {
  public inline function new(element) {
    this = element;
  }

  public inline function getComponent():T {
    return this.getComponent();
  }
}
