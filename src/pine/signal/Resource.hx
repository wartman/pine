package pine.signal;

import pine.Disposable;
import pine.signal.Signal;

using Kit;

enum ResourceStatus<T, E = Error> {
  Loading;
  Ok(data:T);
  Error(error:E);
}

// @todo: Make `T` forced to be serializable?
@:forward
@:forward.new
abstract Resource<T>(ResourceObject<T>) 
  to Disposable 
  to DisposableItem 
{
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
    this.suspense = context.get(Suspense);
  }

  public function fetch<T>(fetch):Resource<T> {
    return new Resource<T>(fetch, suspense);
  }
}

class ResourceObject<T> implements Disposable {
  final suspense:Null<Suspense>;
  final owner:Owner;
  final data:Signal<ResourceStatus<T>>;

  var link:Null<Cancellable>;

  public function new(fetch:()->Task<T>, ?suspense) {
    this.suspense = suspense;

    data = new Signal(Loading);
    owner = new Owner();

    owner.own(() -> Observer.track(() -> {
      link?.cancel();
      data.set(Loading);
      suspense?.markResourceAsSuspended(this);
      link = fetch().handle(result -> switch result {
        case Ok(value): 
          data.set(Ok(value));
          suspense?.markResourceAsCompleted(this);
        case Error(error): 
          data.set(Error(error));
          suspense.markResourceAsFailed(this);
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
    suspense?.markResourceAsCompleted(this);
  }
}
