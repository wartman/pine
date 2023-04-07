package pine2.signal;

import pine2.Disposable;

using Kit;
using Lambda;

abstract NodeVersion(Int) {
  public inline function new() {
    this = 0;
  }

  public inline function increment() {
    this++;
  }

  inline function unwrap():Int {
    return this;
  }

  public inline function compare(other:NodeVersion) {
    return this >= other.unwrap();
  }
}

@:allow(pine2.signal)
interface Node extends Disposable {
  public final id:UniqueId;
  public function getVersion():NodeVersion;
}

@:allow(pine2.signal)
interface ProducerNode extends Node {
  public function notify():Void;
  public function bindConsumer(consumer:ConsumerNode):Void;
  public function unbindConsumer(consumer:ConsumerNode):Void;
}

@:allow(pine2.signal)
interface ConsumerNode extends Node {
  public function isInactive():Bool;
  public function invalidate():Void;
  public function validate():Void;
  public function pollProducers():Bool;
  public function bindProducer(node:ProducerNode):Void;
  public function unbindProducer(node:ProducerNode):Void;
}

private var currentConsumer:Maybe<ConsumerNode> = None;
private final pending:List<ConsumerNode> = new List();
private var depth:Int = 0;

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
