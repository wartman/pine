package pine2.signal;

import pine2.signal.Graph;

using Lambda;

class Computation<T> extends Observer implements ProducerNode {
  final consumers:List<ConsumerNode> = new List();
  var value:T;

  public function new(computation:()->T) {
    super(() -> value = computation());
  }

  public function get():T {
    switch status {
      case Valid:
      default: throw 'oops';
    }

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
    switch status {
      case Valid:
      default: throw 'oops';
    }
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
