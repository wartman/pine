package pine;

@:callable
abstract Action(() -> Void) from () -> Void {
  inline public static function run(handler) {
    StateEngine.get().batch(handler);
  }
  
  public function new(handler) {
    this = () -> StateEngine.get().batch(handler);
  }

  public inline function trigger() {
    this();
  }
}
