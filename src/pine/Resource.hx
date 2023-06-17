package pine;

import pine.Disposable;
import pine.signal.*;
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
abstract Resource<T, E = kit.Error>(ResourceObject<T, E>) to Disposable {
  public inline static function from(context:Component) {
    return new ResourceFactory(context);
  }

  public inline static function collect<T, E>(...resources:Resource<T, E>) {
    return new ResourceCollection(...resources);
  }

  public inline function new(context, fetch, ?options) {
    this = new ResourceObject(context, fetch, options);
  }

  @:op(a())
  public inline function sure() {
    return this.sure();
  }
}

abstract ResourceCollection<T, E>(Computation<ResourceStatus<Array<T>, E>>) to Computation<ResourceStatus<Array<T>, E>> to ReadonlySignal<ResourceStatus<Array<T>, E>> {
  public var loading(get, never):Bool;
  inline function get_loading() {
    return this.get() == Loading;
  }

  public var data(get, never):ReadonlySignal<ResourceStatus<Array<T>, E>>;
  inline function get_data() {
    return this;
  }
  
  public function new(...resources:Resource<T, E>) {
    this = new Computation(() -> {
      var status:ResourceStatus<Array<T>, E> = Loaded([]);
      for (res in resources) switch res.data() {
        case Loading: status = Loading;
        case Loaded(value): switch status {
          case Loaded(values): values.push(value);
          default:
        }
        case Error(e): switch status {
          case Error(_):
          default: status = Error(e);
        }
      }
      return status;
    });
  }

  @:op(a())
  public inline function sure() {
    this.get().extract(Loaded(values));
    return values;
  }
}

// @todo: Add features like mutation and using stale values 
// until a new value is fetched.
private class ResourceObject<T, E = kit.Error> implements Disposable {
  public final data:Signal<ResourceStatus<T, E>>;
  public final loading:ReadonlySignal<Bool>;
  
  final context:Component;
  final fetch:Computation<Task<T, E>>;
  final options:ResourceOptions<T, E>;
  final disposables:DisposableCollection = new DisposableCollection();
  
  var link:Null<Cancellable>;

  public function new(context, fetch, ?options:ResourceOptions<T, E>) {
    this.context = context;
    this.fetch = new Computation(fetch);
    this.options = options ?? {};
    data = new Signal(Loading);
    loading = data.map(status -> status == Loading);

    switch getCurrentOwner() {
      case Some(owner): 
        owner.addDisposable(this);
      case None:
    }

    withOwner(disposables, () -> Observer.track(process));
  }

  public function sure():T {
    data.get().extract(Loaded(value));
    return value;
  }

  function process() {
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
    Suspense.maybeFrom(context).ifExtract(Some(suspense), suspense.await(task));
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
    disposables.dispose();
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
