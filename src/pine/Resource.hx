package pine;

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
  public final ?onHydrate:()->T;
}

// @todo: Add features like mutation and using stale values 
// until a new value is fetched.
class Resource<T, E = kit.Error> implements Disposable {
  public inline static function from(context:Component) {
    return new ResourceFactory(context);
  }
  
  final context:Component;
  final fetch:()->Task<T, E>;
  final onHydrate:Null<()->T>;
  public final data:Signal<ResourceStatus<T, E>>;
  var link:Null<Cancellable>;

  public function new(context, fetch, ?options:ResourceOptions<T, E>) {
    this.context = context;
    this.fetch = fetch;
    this.onHydrate = options?.onHydrate;
    this.data = new Signal(Loading);

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
  
  public function isLoading():Bool {
    return get() == Loading;
  }

  public function refetch() {
    if (link != null) link.cancel();

    if (context.isComponentHydrating()) {
      if (onHydrate != null) {
        data.set(Loaded(onHydrate()));
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
