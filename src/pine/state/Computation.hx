package pine.state;

class Computation<T> extends State<T> {
  final observer:Observer;

  public function new(handler:() -> T, ?comparator) {
    super(null, comparator);
    var first = true;
    this.observer = new Observer(() -> {
      value = handler();
      if (!first) notify();
      first = false;
    });
  }

  override function dispose() {
    super.dispose();
    observer.dispose();
  }

  override function set(value:T):T {
    Debug.error('Computations are read-only');
  }
}