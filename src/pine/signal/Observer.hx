package pine.signal;

import pine.Disposable;
import pine.debug.Debug;
import pine.signal.Graph;
import haxe.Exception;
import kit.UniqueId;

enum abstract ObserverStatus(Int) {
  final Pending;
  final Inactive;
  final Valid;
  final Invalid;
  final Validating;
}

typedef DependencyLink = {
  public final lastSeenVersion:NodeVersion;
  public final node:ProducerNode;
} 

class Observer implements ConsumerNode {
  /**
    Create a root-level Observer. Will return a Disposable
    that can be used to clean up the observable scope.

    Important: you probably don't need to use this! Prefer
    `Observer.track` unless you know what you're doing.
  **/
  public static inline function root(handler):Disposable {
    var owner = new DisposableCollection();
    assert(getCurrentOwner() == None, 'Attempted to use `root` inside an existing scope. Use `track` instead or ensure you are actually calling `root` outside an owner.');
    withOwner(owner, () -> track(handler));
    return owner;
  }

  public static inline function track(handler) {
    return new Observer(handler);
  }

  public static inline function untrack(handler) {
    pine.signal.Graph.untrack(handler);
  }

  public final id:UniqueId = new UniqueId();
  final handler:()->Void;
  final producers:Map<UniqueId, DependencyLink> = [];
  final disposables:DisposableCollection = new DisposableCollection();
  var version:NodeVersion = new NodeVersion();
  var status:ObserverStatus = Pending;

  public function new(handler) {
    this.handler = handler;
    switch getCurrentOwner() {
      case Some(owner):
        owner.addDisposable(this);
      case None:
        warn('Creating an Observer without an owner means it may never get disposed');
    }
    validate();
  }

  public function isInactive() {
    return status == Inactive;
  }

  public function invalidate() {
    switch status {
      case Validating:
        error('Cycle detected');
      case Invalid | Inactive:
      case Valid | Pending:
        status = Invalid;
        enqueueConsumer(this);
    }
  }

  public function validate() {
    switch status {
      case Validating:
        error('Cycle detected');
      case Inactive | Valid:
        return;
      case Invalid if (!pollProducers()):
        status = Valid;
        return;
      default:
    }

    var prevConsumer = setCurrentConsumer(Some(this));
    var prevOwner = setCurrentOwner(Some(disposables));
    var err:Null<Exception> = null;

    status = Validating;

    unbindAll();

    try {
      handler();
    } catch (e) {
      err = e;
    }

    status = Valid;
    version.increment();
    setCurrentConsumer(prevConsumer);
    setCurrentOwner(prevOwner);

    if (err != null) throw err;
  }

  public function getVersion() {
    return version;
  }

  public function pollProducers():Bool {
    for (link in producers) {
      if (!link.lastSeenVersion.compare(link.node.getVersion())) return true;
    }
    return false;
  }

  public function bindProducer(node:ProducerNode) {
    producers.set(node.id, {
      lastSeenVersion: node.getVersion(),
      node: node
    });
  }

  public function unbindProducer(node:ProducerNode) {
    producers.remove(node.id);
  }

  function unbindAll() {
    for (producer in producers) {
      producer.node.unbindConsumer(this);
    }
    producers.clear();
  }

  public function dispose() {
    if (isInactive()) return;
    disposables.dispose();
    status = Inactive;
    unbindAll();
  }
}
