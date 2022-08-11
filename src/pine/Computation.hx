package pine;

class Computation<T> extends State<T>  {
  final observer:Observer;

  public function new(compute:()->T, untracked = false) {
    super(null);
    var first = true;
    observer = new Observer(() -> {
      value = compute();
      if (!first) notify();
      first = false;
    }, untracked);
  }

  override function dispose() {
    observer.dispose();
    super.dispose();
  }
}
