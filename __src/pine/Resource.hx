package pine;

import pine.Component;
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
  public final ?hydrate:(context:Component)->T;
  
  /**
    A callback triggered when the Resource starts loading.
  **/
  public final ?loading:(context:Component)->Void;

  /**
    A callback triggered when the Resource has loaded.
  **/
  public final ?loaded:(context:Component, value:T)->Void;

  /**
    A callback triggered when the Resource errors out.
  **/
  public final ?errored:(context:Component, error:E)->Void;
}

@:forward(data, loading, activate, dispose)
abstract Resource<T, E = kit.Error>(ResourceObject<T, E>) from ResourceObject<T, E> to Disposable {
  public inline static function from(context:Component) {
    return new ResourceFactory(context);
  }

  public inline static function collect<T, E>(...resources:Resource<T, E>):Resource<Array<T>, E> {
    return new ResourceCollectionObject<T, E>(...resources);
  }

  public inline function new(context, fetch, ?options) {
    this = new SimpleResourceObject<T, E>(context, fetch, options);
  }

  @:op(a())
  public inline function sure() {
    return this.sure();
  }
}

interface ResourceObject<T, E = kit.Error> extends Disposable {
  public final data:ReadonlySignal<ResourceStatus<T, E>>;
  public final loading:ReadonlySignal<Bool>;
  public function sure():T;
}

class ResourceCollectionObject<T, E = kit.Error> implements ResourceObject<Array<T>, E> {
  public final data:ReadonlySignal<ResourceStatus<Array<T>, E>>;
  public final loading:ReadonlySignal<Bool>;

  final disposables:DisposableCollection = new DisposableCollection();
  final resources:Array<Resource<T, E>>;

  public function new(...resources:Resource<T, E>) {
    var previousOwner = setCurrentOwner(Some(disposables));
  
    this.resources = resources.toArray();
    data = new Computation(() -> {
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
    loading = data.map(status -> status == Loading);

    setCurrentOwner(previousOwner);
    
    switch getCurrentOwner() {
      case Some(owner):
        owner.addDisposable(this);
      case None:
        // noop
    }
  }

  public function sure():Array<T> {
    data.get().extract(Loaded(value));
    return value;
  }

  public function dispose() {
    disposables.dispose();
  }
}

class SimpleResourceObject<T, E = kit.Error> implements ResourceObject<T, E> {
  public final data:Signal<ResourceStatus<T, E>>;
  public final loading:ReadonlySignal<Bool>;
  
  final fetch:Computation<Task<T, E>>;
  final options:ResourceOptions<T, E>;
  final disposables:DisposableCollection = new DisposableCollection();
  final context:Component;

  var link:Null<Cancellable> = null;

  public function new(context:Component, fetch, ?options:ResourceOptions<T, E>) {
    var previousOwner = setCurrentOwner(Some(disposables));

    this.context = context;
    this.options = options ?? {};
    this.fetch = new Computation(fetch);
    this.data = new Signal(Loading);
    this.loading = data.map(data -> data == Loading);

    Observer.track(process);

    setCurrentOwner(previousOwner);

    context.addDisposable(this);
  }

  public function sure():T {
    data.get().extract(Loaded(value));
    return value;
  }

  function process() {
    if (link != null) link.cancel();

    if (context.isComponentHydrating()) {
      if (options.hydrate != null) {
        data.set(Loaded(options.hydrate(context)));
        return;
      }
    }
    
    data.set(Loading);

    if (options.loading != null) options.loading(context);
    
    var task = fetch();
    Suspense.maybeFrom(context).ifExtract(Some(suspense), suspense.await(task));
    link = task.handle(result -> switch result {
      case Ok(value):
        if (options.loaded != null) options.loaded(context, value);
        data.set(Loaded(value));
      case Error(error):
        if (options.errored != null) options.errored(context, error);
        data.set(Error(error));
    });
  }

  public function dispose() {
    disposables.dispose();
    link?.cancel();
    link = null;
  }
}

abstract ResourceFactory(Component) {
  public inline function new(context) {
    this = context;
  }

  public inline function fetch<T, E>(fetch:()->Task<T, E>, ?options:ResourceOptions<T, E>):Resource<T, E> {
    return new Resource(this, fetch, options);
  }
}
