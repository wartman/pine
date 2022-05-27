package pine;

typedef QueueLink = {
  public function cancel():Void;
}

abstract Queue(Array<() -> Void>) {
  public inline function new(?effects) {
    this = effects != null ? effects : [];
  }

  public inline function copy() {
    return new Queue(this.copy());
  }

  public function enqueue(effect:() -> Void):QueueLink {
    this.push(effect);
    return {
      cancel: () -> this.remove(effect)
    };
  }

  public function dequeue() {
    var effect = this.pop();
    while (effect != null) {
      effect();
      effect = this.pop();
    }
  }
}
