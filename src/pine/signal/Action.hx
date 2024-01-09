package pine.signal;

import pine.signal.Graph;

@:callable
abstract Action(()->Void) {
  inline public static function run(handler) {
    batch(() -> untrack(handler));
  }
  
  inline public function new(handler) {
    this = () -> batch(() -> untrack(handler));
  }

  inline public function trigger() {
    this();
  }
}
