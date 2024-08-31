package pine;

interface Disposable {
	public function dispose():Void;
}

interface DisposableHost {
	public function addDisposable(disposable:DisposableItem):Void;
	public function removeDisposable(disposable:DisposableItem):Void;
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
	var isDisposed:Bool = false;
	final disposables:List<Disposable> = new List();

	public function new() {}

	public function addDisposable(disposable:DisposableItem) {
		if (isDisposed) {
			disposable.dispose();
			return;
		}
		disposables.add(disposable);
	}

	public function removeDisposable(disposable:DisposableItem) {
		disposables.remove(disposable);
	}

	public function dispose() {
		if (isDisposed) return;
		isDisposed = true;
		for (disposable in disposables) {
			disposables.remove(disposable);
			disposable.dispose();
		}
	}
}
