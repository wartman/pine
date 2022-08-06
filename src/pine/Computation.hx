package pine;

class Computation<T> extends State<T>  {
  final observer:Observer;

  public function new(compute:()->T, untracked = false) {
    super(null);
    observer = new Observer(() -> {
      value = compute();
      notify(); // I think this is ok? We may need to defer it though.
    }, untracked);
  }

  override function dispose() {
    observer.dispose();
    super.dispose();
  }
}
