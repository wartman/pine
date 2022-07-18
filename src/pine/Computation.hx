package pine;

class Computation<T> extends State<T>  {
  final observer:Observer;

  public function new(compute:()->T, untracked = false) {
    super(null);
    observer = new Observer(() -> {
      value = compute();
      Process.defer(notify);
    }, untracked);
  }

  override function dispose() {
    observer.dispose();
    super.dispose();
  }
}
