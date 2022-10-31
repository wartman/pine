package pine.state;

import pine.state.Engine;

@:callable
abstract Action(()->Void) {
  inline public static function run(handler) {
    batch(handler);
  }
  
  public function new(handler) {
    this = () -> batch(handler);
  }

  public inline function trigger() {
    this();
  }
}
