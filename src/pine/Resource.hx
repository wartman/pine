package pine;

import haxe.macro.Context;
import pine.debug.Debug;
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

@:forward(data, loading, activate, dispose)
abstract Resource<T, E = kit.Error>(ResourceObject<T, E>) from ResourceObject<T, E> to Disposable {
  public inline static function from(context:Component) {
    return new ResourceFactory(context);
  }

  public inline static function defer<T, E>(fetch, ?options):Resource<T, E> {
    return new DeferredResourceObject(fetch, options);
  }

  public inline static function collect<T, E>(...resources:Resource<T, E>):Resource<Array<T>, E> {
    return new ResourceCollectionObject(...resources);
  }

  public inline function new(context, fetch, ?options) {
    this = new SimpleResourceObject(context, fetch, options);
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
  public function activate(context:Component):Resource<T, E>;
}

class ResourceCollectionObject<T, E = kit.Error> implements ResourceObject<Array<T>, E> {
  public final data:ReadonlySignal<ResourceStatus<Array<T>, E>>;
  public final loading:ReadonlySignal<Bool>;
  final resources:Array<Resource<T, E>>;

  public function new(...resources:Resource<T, E>) {
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
  }

  public function sure():Array<T> {
    data.get().extract(Loaded(value));
    return value;
  }

  public function dispose() {
    // noop
  }

  public function activate(context:Component):Resource<Array<T>, E> {
    for (res in resources) res.activate(context);
    return this;
  }
}

class DeferredResourceObject<T, E = kit.Error> implements ResourceObject<T, E> {
  public final data:ReadonlySignal<ResourceStatus<T, E>>;
  public final loading:ReadonlySignal<Bool>;

  final fetch:()->Task<T, E>;
  final options:ResourceOptions<T, E>;
  final resource:Signal<Maybe<Resource<T, E>>>;
  final disposables:DisposableCollection = new DisposableCollection();

  public function new(fetch, ?options) {
    this.fetch = fetch;
    this.options = options ?? {};

    var prevOwner = setCurrentOwner(Some(disposables));

    resource = new Signal(None);
    data = resource.map(res -> switch res {
      case Some(resource): resource.data();
      case None: Loading;
    });
    loading = data.map(status -> status == Loading);

    setCurrentOwner(prevOwner);
  }
  
  public function activate(context:Component):Resource<T, E> {
    switch resource.peek() {
      case None:
        context.addDisposable(this);
        withOwner(disposables, () -> {
          resource.set(Some(new Resource<T, E>(context, fetch, options)));
        });
      case Some(_):
    }
    return this;
  }

  public function sure():T {
    resource.peek().extract(Some(res));
    return res.sure();
  }

  public function dispose() {
    disposables.dispose();
    resource.set(None);
  }
}

class SimpleResourceObject<T, E = kit.Error> implements ResourceObject<T, E> {
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

  public function activate(context:Component):Resource<T, E> {
    return this;
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

abstract ResourceFactory(Component) {
  public inline function new(context) {
    this = context;
  }

  public inline function fetch<T, E>(fetch:()->Task<T, E>, ?options:ResourceOptions<T, E>):Resource<T, E> {
    return new Resource(this, fetch, options);
  }
}
