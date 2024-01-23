package pine.signal;

import pine.Disposable;
import pine.debug.Debug;
import pine.signal.Signal;
import haxe.Exception;

@:forward
abstract Computation<T>(ComputationObject<T>) 
  from ComputationObject<T>
  to ReadOnlySignal<T>
  to DisposableItem
  to Disposable 
{
  /**
    Eager Computations will always recompute, even if they don't
    have any consumers of their own.
  **/
  public static function eager<T>(value, ?equal):Computation<T> {
    return new ComputationObject(value, equal, true);
  }

  /**
    Lazy computations will only recompute if they have consumers.

    This is the default behavior for Computations and is generally
    recommended.
  **/
  public static function lazy<T>(value, ?equal):Computation<T> {
    return new ComputationObject(value, equal, false);
  }

  public inline function new(value, ?equal) {
    this = new ComputationObject(value, equal);
  }

  @:op(a())
  public inline function get() {
    return this.get();
  }

  @:to
  public inline function asReadOnlySignal():ReadOnlySignal<T> {
    return this;
  }

  public inline function map<R>(transform:(value:T)->R):ReadOnlySignal<R> {
    return new Computation(() -> transform(get()));
  }
}

enum ComputationStatus<T> {
  Uninitialized;
  Computing;
  Disposed(lastValue:T);
  Computed(value:T);
  Errored(e:Exception);
}

class ComputationObject<T> implements Disposable {
  final factory:()->T;
  final equals:(a:T, b:T)->Bool;
  
  var node:Null<ReactiveNode>;
  var status:ComputationStatus<T> = Uninitialized;

  public function new(factory, ?equals, ?alwaysLive:Bool) {
    this.factory = factory;
    this.equals = equals ?? (a, b) -> a == b;
    this.node = new ReactiveNode(Runtime.current(), _ -> compute(), {
      alwaysLive: alwaysLive,
      forceValidation: _ -> switch status  {
        case Uninitialized: true;
        default: false;
      }
    });
    if (alwaysLive == true) Owner.current()?.addDisposable(this);
  }

  public function get():T {
    // We always validate the node to ensure we have the most
    // up-to-date value. This can mean the node is validated
    // before it would usually be scheduled.
    node?.validate();
    node?.accessed();
    return resolveValue();
  }

  public function peek():T {
    node?.validate();
    return resolveValue();
  }

  public function dispose() {
    switch status {
      case Disposed(_):
      case Computed(value):
        status = Disposed(value);
        node?.disconnect();
        node = null;
      default:
        // @todo: Is this an error?
    }
  }

  function resolveValue() {
    return switch status {
      case Uninitialized:
        error('No value computed');
      case Errored(e):
        throw e;
      case Computing:
        error('Cycle detected');
      case Computed(value):
        value;
      case Disposed(lastValue):
        lastValue;
    };
  }

  function compute() {
    switch status {
      case Uninitialized:
        assert(node != null);

        var value:Null<T> = null;

        status = Computing;
        
        try node.useAsCurrentConsumer(() -> value = factory()) catch (e) {
          status = Errored(e);
        }
        
        switch status {
          case Errored(_):
          default: 
            status = Computed(value);
        }
      case Computed(prevValue):
        var value:T = prevValue;

        status = Computing;

        try node.useAsCurrentConsumer(() -> {
          var newValue = factory();
    
          if (equals(prevValue, newValue)) return;
    
          value = newValue;
          node.version++;
        }) catch (e) {
          status = Errored(e);
        }

        switch status {
          case Errored(_):
          default: 
            status = Computed(value);
        }
      default:
    }
  }
}
