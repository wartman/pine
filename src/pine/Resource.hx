package pine;

import pine.Disposable;
import pine.signal.Graph;
import pine.signal.Signal;

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
  
  /**
    A callback triggered when the Resource starts loading.
  **/
  public final ?loading:()->Void;

  /**
    A callback triggered when the Resource has loaded.
  **/
  public final ?loaded:(value:T)->Void;

  /**
    A callback triggered when the Resource errors out.
  **/
  public final ?errored:(error:E)->Void;
}

@:forward
abstract Resource<T, E = kit.Error>(ResourceObject<T, E>)
  from ResourceObject<T, E>
  to Disposable
{
  public inline static function from(context:Component) {
    return new ResourceFactory(context);
  }

  public inline function new(context, fetch, ?options) {
    this = new ResourceObject(context, fetch, options);
  }

  @:op(a())
  public inline function sure() {
    return this.sure();
  }
}

// @todo: Add features like mutation and using stale values 
// until a new value is fetched.
class ResourceObject<T, E = kit.Error> implements Disposable {
  public final data:Signal<ResourceStatus<T, E>>;
  public final loading:ReadonlySignal<Bool>;
  
  final context:Component;
  final fetch:()->Task<T, E>;
  final options:ResourceOptions<T, E>;
  
  var link:Null<Cancellable>;

  public function new(context, fetch, ?options:ResourceOptions<T, E>) {
    this.context = context;
    this.fetch = fetch;
    this.options = options ?? {};
    data = new Signal(Loading);
    loading = data.map(status -> status == Loading);

    switch getCurrentOwner() {
      case Some(owner): 
        owner.addDisposable(this);
      case None:
    }

    refetch();
  }

  public function sure():T {
    data.get().extract(Loaded(value));
    return value;
  }

  public function refetch() {
    if (link != null) link.cancel();

    if (context.isComponentHydrating()) {
      if (options.hydrate != null) {
        data.set(Loaded(options.hydrate()));
        return;
      }
      // @todo: Throw if we try to hydrate and we don't have a sync
      // way of getting data?
    }

    if (options.loading != null) options.loading();
    data.set(Loading);
    var task = fetch();
    Suspense.maybeFrom(context).unwrap()?.await(task);
    link = task.handle(result -> switch result {
      case Ok(value):
        if (options.loaded != null) options.loaded(value);
        data.set(Loaded(value));
      case Error(error):
        if (options.errored != null) options.errored(error);
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
