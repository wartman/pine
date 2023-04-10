package pine2.signal;

import pine2.signal.Graph;

using Lambda;

class Computation<T> extends Observer implements ProducerNode {
  final consumers:List<ConsumerNode> = new List();
  final equals:(a:T, b:T) -> Bool;
  var value:T;

  public function new(computation:()->T, ?equals) {
    this.equals = equals ?? (a, b) -> a == b;
    super(() -> {
      var newValue = computation();
      if (this.equals(value, newValue)) return;
      version.increment();
      this.value = newValue;
      notify();
    });
  }

  public function get():T {
    switch getCurrentConsumer() {
      case None:
      case Some(consumer) if (consumer == this):
        throw 'Cannot observe self';
      case Some(consumer):
        consumer.bindProducer(this);
        bindConsumer(consumer);
    }

    return value;
  }

  public function peek() {
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

  override function dispose() {
    super.dispose();
    for (consumer in consumers) {
      unbindConsumer(consumer);
      consumer.unbindProducer(this);
    }
  }
}
