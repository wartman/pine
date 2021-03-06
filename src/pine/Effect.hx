package pine;

abstract Effect(InitContext) {
  public inline static function on(context:InitContext) {
    return new Effect(context);
  }

  inline function new(context) {
    this = context;
  }

  public inline function add(effect:()->Void) {
    Process.defer(() -> {
      Cleanup.on(this).add(new Observer(effect));
    });
  }
}
