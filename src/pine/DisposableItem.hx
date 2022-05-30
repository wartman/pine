package pine;

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
