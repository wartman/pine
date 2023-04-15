package pine;

import pine.Disposable;

@:autoBuild(pine.internal.macro.ReactiveObjectBuilder.build())
abstract class Record implements Disposable implements DisposableHost {
  final disposables:DisposableCollection = new DisposableCollection();

  public function addDisposable(disposable:DisposableItem):Void {
    disposables.addDisposable(disposable);
  }

  public function dispose() {
    disposables.dispose();
  }
}
