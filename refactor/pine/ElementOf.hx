package pine;

@:forward
abstract ElementOf<T:Component>(Element) from Element {
  public inline function new(element) {
    this = element;
  }

  public inline function getComponent():T {
    return this.getComponent();
  }
}
