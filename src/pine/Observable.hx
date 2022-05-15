package pine;

typedef ObservableOptions<T> = {
  /**
    If `true` the Observable will be disposed if it no longer
    has any Observers attached to it. This is used mostly by
    linked Observables returned by `Observable.map` to guard against
    memory leaks.
  **/
  public var ?autoDispose:Bool;

  /**
    Compares the current and the new value in the Observable. If
    `true` the Observable will change its value and notify all 
    its Observers. If `false` nothing will happen.

    By default, this is a simple equality (a != b) check.
  **/
  public var ?shouldUpdate:ObservableShouldUpdate<T>;
}

typedef ObservableBindingOptions = {
  /**
    If true, the Observer will not be run immediately but will wait
    for the next time its Observer notifys it of a change.

    This is `false` by default.
  **/
  public var defer:Bool;
}

typedef ObservableShouldUpdate<T> = (a:T, b:T) -> Bool;

@:allow(pine.Observable)
private class Observer<T> implements Disposable {
  final listener:(observedValue:T) -> Void;

  var isDisposed:Bool = false;
  var observable:Null<Observable<T>>;
  var next:Null<Observer<T>>;

  public function new(observable:Observable<T>, listener) {
    this.listener = listener;
    this.observable = observable;
  }

  public function handle(observedValue:T) {
    listener(observedValue);
  }

  final public function dispose() {
    if (isDisposed) return;
    if (observable != null) observable.remove(this);
  }

  function cleanupOnRemoved() {
    if (isDisposed) return;
    isDisposed = true;
    if (observable != null) {
      observable = null;
      next = null;
    }
  }
}

@:allow(pine.Observable)
private class LinkedObserver<T, R> extends Observer<T> {
  final linkedObservable:Observable<R>;

  public function new(parent:Observable<T>, linked:Observable<R>, transform:(observedValue:T) -> R) {
    linkedObservable = linked;
    linkedObservable.observerLink = this;
    super(parent, observedValue -> linkedObservable.update(transform(observedValue)));
  }

  public function observe():Observable<R> {
    return linkedObservable;
  }

  override function cleanupOnRemoved() {
    super.cleanupOnRemoved();
    linkedObservable.observerLink = null;
    linkedObservable.dispose();
  }
}

enum abstract HandleableObserverStatus(Bool) {
  var Handled = true;
  var Pending = false;
}

private class HandleableObserver<T> extends Observer<T> {
  public function new(observable, listener:(observedValue:T) -> HandleableObserverStatus) {
    super(observable, observedValue -> {
      switch (listener(observedValue)) {
        case Handled: dispose();
        case Pending: // noop
      }
    });
  }
}

@:allow(pine.Observer)
class Observable<T> implements Disposable {
  static var uid:Int = 0;

  final shouldUpdate:ObservableShouldUpdate<T>;
  final shouldAutoDispose:Bool;

  var isNotifying:Bool = false;
  var isDisposed:Bool = false;
  var observedValue:T;
  var observerLink:Null<Disposable> = null;
  var observerListHead:Null<Observer<T>>;
  var observerListToAddHead:Null<Observer<T>>;

  public var length(get, never):Int;

  function get_length() {
    var len = 0;
    var current = observerListHead;
    while (current != null) {
      len++;
      current = current.next;
    }
    return len;
  }

  public function new(observedValue, ?options:ObservableOptions<T>) {
    if (options == null) {
      options = {};
    }
    this.observedValue = observedValue;
    shouldUpdate = if (options.shouldUpdate == null) (a, b) -> a != b else options.shouldUpdate;
    shouldAutoDispose = if (options.autoDispose == null) false else options.autoDispose;
  }

  public inline function observe() {
    // note: Allows this to be used as an ObservableHost
    return this;
  }

  public function bind(listener:(observedValue:T) -> Void, ?options:ObservableBindingOptions):Disposable {
    if (options == null) {
      options = {defer: false};
    }

    var observer = new Observer(this, listener);
    addObserver(observer, options);

    return observer;
  }

  public inline function bindNext(listener) {
    return bind(listener, {defer: true});
  }

  public function handle(listener:(observedValue:T) -> HandleableObserverStatus, ?options:ObservableBindingOptions):Disposable {
    if (options == null) options = {defer: false};

    var observer = new HandleableObserver(this, listener);
    addObserver(observer, options);

    return observer;
  }

  public function handleNext(listener) {
    return handle(listener, {defer: true});
  }

  public inline function next(listener) {
    return handleNext(observedValue -> {
      listener(observedValue);
      return Handled;
    });
  }

  /**
    Create a new Observable that is linked to this one, and will update
    whenever its parent's value changes.

    By default the returned Observable will automatically dispose itself once
    it no longer has any Observers. You can override this by setting
    `{autoDispose: false}` in the `options` argument or by using 
    `Observable.mapPersistent` instead. This is generally not advised
    unless you really need it -- read the comment on `Observable.mapPersistent`
    for more.

    Note that in `debug` mode this method will throw an exception if you
    try to map from a linked Observable that is not automatically disposable.
  **/
  public function map<R>(transform:(observedValue:T) -> R, ?options:ObservableOptions<R>):Observable<R> {
    if (options == null) {
      options = {};
    }

    if (options.autoDispose == null) {
      options.autoDispose = true;
    }

    #if debug
    if (observerLink != null) {
      // @todo: We need to come up with better language for this :V
      Debug.assert(shouldAutoDispose, 'Parents of linked Observables must either not be linked themselves or must be automatically disposable.');
    }
    #end

    var observer = new LinkedObserver(this, new Observable(transform(observedValue), options), transform);
    addObserver(observer, {defer: true});
    return observer.observe();
  }

  /**
    Create a linked Observable that does **not** automatically dispose itself.
    Be careful with this method -- only use it in cases where you know an
    Observable might be reused.

    In addition, only use `mapPersistent` at the end of a chain. If you don't,
    some Observers may never be removed and you could end up with a memory leak.

    For example:

    **DO**

    ```haxe
    var fooBar = foo
      .map(data -> data + ' bar')
      .mapPersistent(data -> data + ' .');
    fooBar.dispose();
    ```

    In the above example, when `fooBar.dispose()` is called its parent
    Observable will be removed as well (as it will no longer have any
    Observers).

    **DON'T**

    ```haxe
    var fooBar = foo
      .mapPersistent(data -> data + ' bar')
      .mapPersistent(data -> data + ' .');
    fooBar.dispose();
    ```

    In the above example, `fooBar`'s parent Observable will NEVER be 
    disposed, and the user will have no way to get at it (other than
    calling `foo.dispose()`), and will throw an exception if `-D debug`
    is defined.
  **/
  public inline function mapPersistent<R>(transform, ?shouldUpdate):Observable<R> {
    return map(transform, {
      shouldUpdate: shouldUpdate,
      autoDispose: false
    });
  }

  public inline function render(render) {
    return new ObservableComponent({
      observable: this,
      render: (observedValue, _) -> render(observedValue)
    });
  }

  public inline function read():T {
    return observedValue;
  }

  function addObserver(observer:Observer<T>, options:ObservableBindingOptions) {
    Debug.assert(isDisposed != true);

    if (isNotifying) {
      observer.next = observerListToAddHead;
      observerListToAddHead = observer;
    } else {
      observer.next = observerListHead;
      observerListHead = observer;
    }

    if (!options.defer) observer.handle(observedValue);
  }

  public function notify() {
    Debug.assert(isDisposed != true, 'Attempted to notify a disposed Observable');

    if (isNotifying) return;

    isNotifying = true;

    var current = observerListHead;

    while (current != null) {
      current.handle(this.observedValue);
      current = current.next;
    }

    isNotifying = false;

    if (observerListToAddHead != null) {
      if (current != null) {
        current.next = observerListToAddHead;
      } else {
        observerListHead = observerListToAddHead;
      }
      observerListToAddHead = null;
    }
  }

  public function update(observedValue:T):Void {
    if (shouldUpdate != null && !shouldUpdate(this.observedValue, observedValue)) return;
    this.observedValue = observedValue;
    notify();
  }

  public function remove(observer:Observer<T>):Void {
    inline function maybeAutoDispose() {
      if (!isDisposed && shouldAutoDispose && observerListHead == null && observerListToAddHead == null) {
        dispose();
      }
    }

    inline function iterate(observerListHead:Null<Observer<T>>) {
      var current = observerListHead;
      while (current != null) {
        if (current.next == observer) {
          current.next = observer.next;
          break;
        }
        current = current.next;
      }
    }

    if (observerListHead == observer) {
      observerListHead = observer.next;
      maybeAutoDispose();
      return;
    }

    iterate(observerListHead);
    iterate(observerListToAddHead);
    maybeAutoDispose();

    observer.cleanupOnRemoved();
  }

  public function dispose():Void {
    Debug.assert(isDisposed != true, 'Attempted to dispose an Observable that was already disposed.');

    isDisposed = true;

    inline function iterate(observerListHead:Null<Observer<T>>) {
      var current = observerListHead;
      while (current != null) {
        var next = current.next;
        current.dispose();
        current = next;
      }
    }

    iterate(observerListHead);
    iterate(observerListToAddHead);

    observerListHead = null;
    observerListToAddHead = null;

    if (observerLink != null) {
      observerLink.dispose();
      observerLink = null;
    }
  }
}
