package pine;

@:callable
abstract Action(() -> Void) from () -> Void {
  inline public static function run(handler) {
    Observer.batchValidateObservers(handler);
  }
  
  public function new(handler) {
    this = () -> Observer.batchValidateObservers(handler);
  }

  public inline function trigger() {
    this();
  }
}
