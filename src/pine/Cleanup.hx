package pine;

abstract Cleanup(InitContext) {
  public inline static function on(context:InitContext) {
    return new Cleanup(context);
  }

  inline function new(context) {
    this = context;
  }

  public inline function add(item) {
    this.addDisposable(item);
  }
}
