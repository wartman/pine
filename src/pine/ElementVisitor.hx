package pine;

abstract ElementVisitor((element:Element) -> Void) from(element:Element) -> Void {
  public inline function new(visitor) {
    this = visitor;
  }

  public inline function visit(element) {
    this(element);
  }
}
