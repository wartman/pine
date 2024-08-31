package pine.signal;

import pine.Disposable;
import pine.signal.Signal;

enum ResourceStatus<T, E = Error> {
	Loading;
	Ok(data:T);
	Error(error:E);
}

// @todo: Make `T` forced to be serializable?

@:forward
@:forward.new
abstract Resource<T, E = Error>(ResourceObject<T, E>) to Disposable to DisposableItem to ReadOnlySignal<ResourceStatus<T, E>> {
	public static function suspends(context:View) {
		return new ResourceBuilder(context);
	}

	@:op(a())
	public inline function get() {
		return this.get();
	}
}

class ResourceBuilder {
	final suspense:Null<Suspense>;

	public function new(context:View) {
		this.suspense = Suspense.maybeFrom(context);
	}

	public function fetch<T>(fetch):Resource<T> {
		return new Resource<T>(fetch, suspense);
	}
}

class ResourceObject<T, E = Error> implements Disposable {
	final suspense:Null<Suspense>;
	final owner:Owner;
	final data:Signal<ResourceStatus<T, E>>;

	var link:Null<Cancellable>;

	public function new(fetch:() -> Task<T, E>, ?suspense) {
		this.suspense = suspense;

		data = new Signal(Loading);
		owner = new Owner();

		owner.own(() -> Observer.track(() -> {
			link?.cancel();

			var handled = false;

			link = fetch().handle(result -> switch result {
				case Ok(value):
					handled = true;
					data.set(Ok(value));
					suspense?.markResourceAsCompleted(this);
				case Error(error):
					handled = true;
					data.set(Error(error));
					suspense?.markResourceAsFailed(this);
			});

			if (!handled) {
				data.set(Loading);
				suspense?.markResourceAsSuspended(this);
			}
		}));

		Owner.current()?.addDisposable(this);
	}

	public inline function get() {
		return data.get();
	}

	public inline function peek() {
		return data.peek();
	}

	public function dispose() {
		owner.dispose();
		link?.cancel();
		link = null;
		suspense?.markResourceAsCompleted(this);
	}
}
