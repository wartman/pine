package pine.signal;

import pine.Disposable;
import pine.signal.Signal;
import pine.signal.Graph;
import pine.debug.Debug;

using Kit;
using Lambda;

@:forward
abstract Computation<T>(ComputationObject<T>) 
  from ComputationObject<T> 
  to ReadonlySignal<T>
  to Disposable
  to DisposableItem
{
  public inline function new(computation, ?equals) {
    this = new ComputationObject(computation, equals);
  }

  @:op(a()) 
  public inline function get():T {
    return this.get();
  }
}

class ComputationObject<T> extends Observer implements ProducerNode {
  final consumers:List<ConsumerNode> = new List();
  final equals:(a:T, b:T) -> Bool;
  var value:Maybe<T> = None;

  public function new(computation:()->T, ?equals) {
    this.equals = equals ?? (a, b) -> a == b;
    super(() -> {
      var newValue = computation();
      switch value {
        case Some(oldValue) if (this.equals(oldValue, newValue)):
          // noop
        case Some(_):
          version.increment();
          value = Some(newValue);
          notify();
        case None:
          value = Some(newValue);
      }
    });
  }

  public function get():T {
    if (isInactive()) return resolveValue();

    switch getCurrentConsumer() {
      case None:
      case Some(consumer) if (consumer == this):
        error('Cannot observe self');
      case Some(consumer):
        consumer.bindProducer(this);
        bindConsumer(consumer);
    }

    return resolveValue();
  }

  public function peek():T {
    return resolveValue();
  }

  public inline function map<R>(transform:(value:T)->R):ReadonlySignal<R> {
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

  inline function resolveValue() {
    return switch value {
      case Some(value): value;
      case None: error('Value was not initialized');
    }
  }

  override function dispose() {
    super.dispose();
    for (consumer in consumers) {
      unbindConsumer(consumer);
      consumer.unbindProducer(this);
    }
  }
}
