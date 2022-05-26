package pine;

// @todo: Rethink this
abstract Effect(Event<Root>) {
  public inline static function from(context:Context) {
    return new Effect(context.getRoot());
  }

  public inline function new(root:Root) {
    this = root.onRenderComplete;
  }

  public inline function add(listener) {
    return this.addListener(listener, { once: true });
  }
}
