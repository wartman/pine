package pine;

import pine.Disposable;

class Owner implements DisposableHost implements Disposable {
  static var currentOwner:Null<DisposableHost> = null;

  public static function setCurrent(owner:DisposableHost) {
    var prev = currentOwner;
    currentOwner = owner;
    return prev;
  }
  
  public static function current() {
    return currentOwner;
  }

  public static function with<T>(owner:DisposableHost, scope:()->T):T {
    var prev = setCurrent(owner);
    var value = scope();
    setCurrent(prev);
    return value;
  }

  final disposables:DisposableCollection = new DisposableCollection();

  public function new() {}

  public function own<T>(scope:()->T) {
    var prev = setCurrent(this);
    var value = scope();
    setCurrent(prev);
    return value;
  }

  public function addDisposable(disposable:DisposableItem):Void {
    disposables.addDisposable(disposable);
  }
  
  public function removeDisposable(disposable:DisposableItem):Void {
    disposables.removeDisposable(disposable);
  }

  public function dispose() {
    disposables.dispose();
  }
}
