package pine.signal;

import pine.Disposable;

using Kit;
using Lambda;

abstract NodeVersion(Int) {
  public inline function new() {
    this = 0;
  }

  public inline function increment() {
    this++;
  }

  @:to inline function unwrap():Int {
    return this;
  }

  public inline function compare(other:NodeVersion) {
    return this >= other.unwrap();
  }
}

@:allow(pine.signal)
interface Node extends Disposable {
  public final id:UniqueId;
  public function isInactive():Bool;
  public function getVersion():NodeVersion;
}

@:allow(pine.signal)
interface ProducerNode extends Node {
  public function notify():Void;
  public function bindConsumer(consumer:ConsumerNode):Void;
  public function unbindConsumer(consumer:ConsumerNode):Void;
}

@:allow(pine.signal)
interface ConsumerNode extends Node {
  public function invalidate():Void;
  public function validate():Void;
  public function pollProducers():Bool;
  public function bindProducer(node:ProducerNode):Void;
  public function unbindProducer(node:ProducerNode):Void;
}

private var currentOwner:Maybe<DisposableHost> = None;
private var currentConsumer:Maybe<ConsumerNode> = None;
private final pending:List<ConsumerNode> = new List();
private var depth:Int = 0;

function withOwner(owner:DisposableHost, cb:()->Void) {
  var prev = setCurrentOwner(Some(owner));
  try cb() catch (e) {
    setCurrentOwner(prev);
    throw e;
  }
  setCurrentOwner(prev);
}

inline function getCurrentOwner() {
  return currentOwner;
}

function setCurrentOwner(owner:Maybe<DisposableHost>) {
  var prev = currentOwner;
  currentOwner = owner;
  return prev;
}

function withConsumer(consumer:ConsumerNode, cb:()->Void) {
  var prev = setCurrentConsumer(Some(consumer));
  try cb() catch (e) {
    setCurrentConsumer(prev);
    throw e;
  }
  setCurrentConsumer(prev);
}

inline function getCurrentConsumer() {
  return currentConsumer;
}

function setCurrentConsumer(consumer:Maybe<ConsumerNode>) {
  var prev = currentConsumer;
  currentConsumer = consumer;
  return prev;
}

function enqueueConsumer(node:ConsumerNode) {
  if (!pending.has(node)) pending.add(node);
  validateConsumers(); // @todo: in the future, this should be scheduled.
}

function validateConsumers() {
  if (depth > 0) return;
  for (consumer in pending) {
    pending.remove(consumer);
    consumer.validate();
  }
}

function batch(compute:()->Void) {
  depth++;
  compute();
  depth--;
  validateConsumers();
}

function untrack(compute:()->Void) {
  var prev = setCurrentConsumer(None);
  batch(compute);
  setCurrentConsumer(prev);
}

function untrackValue<T>(compute:()->T) {
  var prev = setCurrentConsumer(None);
  var value = compute();
  setCurrentConsumer(prev);
  return value;
}
