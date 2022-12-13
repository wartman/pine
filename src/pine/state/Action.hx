package pine.state;

import pine.state.Engine;

@:callable
abstract Action(()->Void) {
  inline public static function run(handler) {
    batch(handler);
  }
  
  inline public function new(handler) {
    this = () -> batch(handler);
  }

  inline public function trigger() {
    this();
  }
}
