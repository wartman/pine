package pine;

import pine.signal.Signal.ReadonlySignal;
import pine.signal.*;
import pine.signal.Graph;

using Kit;

enum ResourceStatus<T, E = kit.Error> {
  Loading;
  Loaded(value:T);
  Error(e:E);
}

typedef ResourceOptions<T, E> = {
  /**
    Get data synchronously if the parent component is hydrating,
    ensuring that hydration will work properly.
  **/
  public final ?hydrate:()->T;
}

// @todo: Add features like mutation and using stale values 
// until a new value is fetched.
class Resource<T, E = kit.Error> implements Disposable {
  public inline static function from(context:Component) {
    return new ResourceFactory(context);
  }
  
  final context:Component;
  final fetch:()->Task<T, E>;
  final hydrate:Null<()->T>;
  public final data:Signal<ResourceStatus<T, E>>;
  public final loading:ReadonlySignal<Bool>;
  var link:Null<Cancellable>;

  public function new(context, fetch, ?options:ResourceOptions<T, E>) {
    this.context = context;
    this.fetch = fetch;
    hydrate = options?.hydrate;
    data = new Signal(Loading);
    loading = data.map(status -> status == Loading);

    switch getCurrentOwner() {
      case Some(owner): 
        owner.addDisposable(this);
      case None:
    }

    refetch();
  }

  public function get():ResourceStatus<T, E> {
    return data.get();
  }

  public function refetch() {
    if (link != null) link.cancel();

    if (context.isComponentHydrating()) {
      if (hydrate != null) {
        data.set(Loaded(hydrate()));
        return;
      }
      // @todo: Throw if we try to hydrate and we don't have a sync
      // way of getting data?
    }

    data.set(Loading);
    var task = fetch();
    Suspense.maybeFrom(context).unwrap()?.await(task);
    link = task.handle(result -> switch result {
      case Ok(value):
        data.set(Loaded(value));
      case Error(error):
        data.set(Error(error));
    });
  }

  public function dispose() {
    if (link != null) {
      link.cancel();
      link = null;
    }
  }
}

private class ResourceFactory {
  final context:Component;

  public function new(context) {
    this.context = context;
  }

  public function fetch<T, E>(fetch:()->Task<T, E>, ?options:ResourceOptions<T, E>):Resource<T, E> {
    return new Resource(context, fetch, options);
  }
}
