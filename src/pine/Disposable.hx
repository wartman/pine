package pine;

interface Disposable {
  public function dispose():Void;
}

interface DisposableHost {
  public function addDisposable(disposable:DisposableItem):Void;
}

@:forward
abstract DisposableItem(Disposable) from Disposable to Disposable {
  @:from
  public inline static function ofCallback(handler:() -> Void):DisposableItem {
    return new DisposableCallback(handler);
  }
}

final class DisposableCallback implements Disposable {
  final handler:() -> Void;

  public function new(handler) {
    this.handler = handler;
  }

  public function dispose() {
    handler();
  }
}

final class DisposableCollection implements Disposable implements DisposableHost {
  final disposables:List<Disposable> = new List();

  public function new() {}

  public function addDisposable(disposable:DisposableItem) {
    disposables.add(disposable);
  }

  public function dispose() {
    for (disposable in disposables) {
      disposables.remove(disposable);
      disposable.dispose();
    }
  }
}
