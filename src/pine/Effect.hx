package pine;

abstract Effect(InitContext) {
  public inline static function from(context:InitContext) {
    return new Effect(context);
  }

  public inline function new(context) {
    this = context;
  }

  public inline function add(effect:()->Void) {
    Process.defer(() -> {
      this.addDisposable(new Observer(effect));
    });
  }
}
