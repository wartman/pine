package pine;

abstract Effect(Observable<Root>) {
  public inline static function from(context:Context) {
    return new Effect(context.getRoot());
  }

  public inline function new(root:Root) {
    this = root.observe();
  }

  public inline function add(listener) {
    return this.next(listener);
  }
}
