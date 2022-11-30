package pine;

@:forward
abstract ContextOf<T:Component>(Context) from Context {
  public inline function new(element) {
    this = element;
  }

  public inline function getComponent():T {
    return this.getComponent();
  }
}
