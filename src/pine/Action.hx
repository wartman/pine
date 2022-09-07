package pine;

@:allow(pine)
class Action {
  final handler:() -> Void;
  
  public function new(handler) {
    this.handler = handler;
  }

  public function trigger() {
    Engine.get().batch(handler);
  }
}
