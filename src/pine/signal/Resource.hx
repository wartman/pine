package pine.signal;

import pine.Disposable;
import pine.signal.Signal.ReadOnlySignal;
using Kit;

enum ResourceStatus<T, E = Error> {
  Loading;
  Ok(data:T);
  Error(error:E);
}

final ResourceNoOpSource:()->Null<Any> = () -> null;

// @todo: Make `T` forced to be serializable
@:forward
@:forward.new
abstract Resource<Query, T>(ResourceObject<Query, T>) 
  to Disposable 
  to DisposableItem 
{
  public static function once<T>(fetch:()->Task<T>) {
    return new Resource(ResourceNoOpSource, _ -> fetch());
  }

  @:op(a())
  public inline function get() {
    return this.get();
  }
}

class ResourceObject<Query, T> implements Disposable {
  final data:Signal<ResourceStatus<T>>;
  final owner:Owner;

  var link:Null<Cancellable>;

  public function new(
    source:ReadOnlySignal<Query>,
    fetch:(query:Query)->Task<T>
  ) {
    data = new Signal(Loading);
    owner = new Owner();

    owner.own(() -> Observer.track(() -> {
      link?.cancel();
      data.set(Loading);

      link = fetch(source()).handle(result -> switch result {
        case Ok(value): data.set(Ok(value));
        case Error(error): data.set(Error(error));
      });
    }));

    Owner.current()?.addDisposable(this);
  }

  public inline function get() {
    return data.get();
  }

  public function dispose() {
    owner.dispose();
    link?.cancel();
    link = null;
  }
}
