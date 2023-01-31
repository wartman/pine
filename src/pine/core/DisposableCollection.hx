package pine.core;

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
