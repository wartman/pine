package pine.signal;

import pine.debug.Debug;
import pine.signal.Computation;
import pine.signal.Graph;

using Kit;
using Lambda;

@:forward
abstract Signal<T>(SignalObject<T>)
  from SignalObject<T>
  to ReadOnlySignal<T> 
{
  @:from public static function ofValue<T>(value:T):Signal<T> {
    return new Signal(value);
  }

  public inline function new(value:T) {
    this = new SignalObject(value);
  }

  @:op(a())
  public inline function get():T {
    return this.get();
  }
}

class SignalObject<T> implements ProducerNode {
  public final id = new UniqueId();
  var isDisposed:Bool = false;
	var version:NodeVersion = new NodeVersion();
  var value:T;
  final equals:(a:T, b:T) -> Bool;
  final consumers:List<ConsumerNode> = new List();

  public function new(value, ?equals) {
    this.value = value;
    this.equals = equals ?? (a, b) -> a == b;
    switch getCurrentOwner() {
      case Some(owner):
        owner.addDisposable(this);
      case None:
        // This should be fine for Signals -- if there is
        // no Owner, we can assume that this is a global signal.
    }
  }

  public function getVersion() {
    return version;
  }

  public function set(newValue:T):T {
    if (isDisposed) {
      warn('Attempted to set a disposed signal');
      return value;
    }
    
    if (equals(value, newValue)) {
      return value;
    }

    value = newValue;
    version.increment();
    notify();
    return value;
  }

  public function get():T {
    if (isDisposed) {
      return value;
    }

    switch getCurrentConsumer() {
      case None:
      case Some(consumer):
        consumer.bindProducer(this);
        bindConsumer(consumer);
    }

    return value;
  }

  public function update(updater:(value:T)->T) {
    return set(untrackValue(() -> updater(peek())));
  }

  public function peek() {
    return value;
  }

  public inline function map<R>(transform:(value:T)->R):ReadOnlySignal<R> {
    return new Computation(() -> transform(get()));
  }

  public function notify() {
    for (consumer in consumers) if (consumer.isInactive()) {
      consumers.remove(consumer);
    } else {
      consumer.invalidate();
    }
  }

  public function bindConsumer(consumer:ConsumerNode) {
    if (consumers.exists(node -> node.id == consumer.id)) return;
    consumers.push(consumer);
  }

  public function unbindConsumer(consumer:ConsumerNode) {
    consumers.remove(consumer);
  }

  public function isInactive() {
    return isDisposed;
  }

  public function dispose() {
    if (isDisposed) return;

    isDisposed = true;
    
    for (consumer in consumers) {
      unbindConsumer(consumer);
      consumer.unbindProducer(this);
    }
  }
}

@:forward
abstract ReadOnlySignal<T>(ReadOnlySignalObject<T>) 
  from ReadOnlySignalObject<T>
  from SignalObject<T>
  from ComputationObject<T>
{
  @:from public inline static function ofSignal<T>(signal:Signal<T>):ReadOnlySignal<T> {
    return signal;
  }

  @:from public inline static function ofReadOnlySignal<T>(signal:ReadOnlySignal<T>):ReadOnlySignal<T> {
    // This seems daft, but we need this method to ensure `ofValue` doesn't 
    // get used incorrectly.
    return signal;
  }

  @:from public inline static function ofValue<T>(value:T):ReadOnlySignal<T> {
    return new Signal(value);
  }

  public inline function new(value:T) {
    this = new SignalObject(value);
  }
  
  public inline function map<R>(transform:(value:T)->R):ReadOnlySignal<R> {
    return new Computation(() -> transform(get()));
  }

  @:op(a())
  public inline function get():T {
    return this.get();
  }
}

typedef ReadOnlySignalObject<T> = {
  public function get():T;
  public function peek():T;
  public function isInactive():Bool;
}
