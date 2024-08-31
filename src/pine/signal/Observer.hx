package pine.signal;

import pine.Disposable;

@:forward(dispose)
abstract Observer(ObserverObject) to DisposableItem to Disposable {
	public static function untrack<T>(effect:() -> T):T {
		return Runtime.current().untrack(effect);
	}

	public inline static function track(effect:() -> Void) {
		return new Observer(effect);
	}

	public function new(effect:() -> Void) {
		this = new ObserverObject(effect);
	}
}

class ObserverObject implements Disposable {
	var node:Null<ReactiveNode>;

	public function new(effect:() -> Void) {
		this.node = new ReactiveNode(Runtime.current(), node -> node.useAsCurrentConsumer(effect), {
			alwaysLive: true
		});
		node.useAsCurrentConsumer(effect);
		Owner.current()?.addDisposable(this);
	}

	public function dispose() {
		if (node == null) return;
		node.disconnect();
		node = null;
	}
}
