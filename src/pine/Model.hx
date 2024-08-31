package pine;

import pine.Disposable;

@:autoBuild(pine.ModelBuilder.build())
abstract class Model implements DisposableHost implements Disposable {
	final disposables:DisposableCollection = new DisposableCollection();

	public function addDisposable(disposable) {
		this.disposables.addDisposable(disposable);
	}

	public function removeDisposable(disposable) {
		this.disposables.removeDisposable(disposable);
	}

	public function dispose() {
		disposables.dispose();
	}
}
