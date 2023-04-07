package pine.signal;

import pine.core.UniqueId;
import pine.signal.Graph;

using Lambda;

class Signal<T> implements ProducerNode {
  public final id = new UniqueId();
	var version:NodeVersion = new NodeVersion();
  var value:T;
  final equals:(a:T, b:T) -> Bool;
  final consumers:List<ConsumerNode> = new List();

  public function new(value, ?equals) {
    this.value = value;
    this.equals = equals ?? (a, b) -> a == b;
  }

  public function getVersion() {
    return version;
  }

  public function set(newValue:T):T {
    if (equals(value, newValue)) return value;
    value = newValue;
    version.increment();
    notify();
    return value;
  }

  public function get():T {
    switch getCurrentConsumer() {
      case None:
      case Some(consumer):
        consumer.bindProducer(this);
        bindConsumer(consumer);
    }
    return value;
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

  public function dispose() {
    for (consumer in consumers) {
      unbindConsumer(consumer);
      consumer.unbindProducer(this);
    }
  }
}
