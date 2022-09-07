package pine;

import pine.internal.Tracking;

@:callable
abstract Action(() -> Void) from () -> Void {
  inline public static function run(handler) {
    batchInvalidateStates(handler);
  }
  
  public function new(handler) {
    this = () -> batchInvalidateStates(handler);
  }

  public inline function trigger() {
    this();
  }
}
