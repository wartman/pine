package pine;

abstract Task(Array<Observer>) {
  public static var currentTask:Null<Task>;

  public inline static function batch(scope:(task:Task) -> Void) {
    if (currentTask != null) {
      scope(currentTask);
      return;
    }

    var task = currentTask = new Task();
    scope(currentTask);

    // Reset the scop in case we trigger any new computations.
    currentTask = null;

    // Trigger our observers.
    task.dequeue();
  }

  public inline function new() {
    this = [];
  }

  public inline function enqueue(observer) {
    if (!this.contains(observer)) this.push(observer);
  }

  public inline function dequeue() {
    var observer = this.pop();
    while (observer != null) {
      observer.trigger();
      observer = this.pop();
    }
  }
}
