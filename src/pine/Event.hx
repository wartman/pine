package pine;

typedef EventListenerOptions = {
  public final once:Bool;
} 

class Event<T> implements Disposable {
  var isDisposed:Bool = false;
  var isDispatching:Bool = false;
  var head:Null<EventListener<T>>;
  var tail:Null<EventListener<T>>;
  var toAddHead:Null<EventListener<T>>;
  var toAddTail:Null<EventListener<T>>;

  public function new() {}

  public function addListener(listener, ?options:EventListenerOptions):Disposable {
    if (isDisposed) {
      Debug.error('Cannot add a listener to a disposed event');
    }

    if (options == null) options = { once: false };
    var listener = new EventListener(this, listener, options.once);
    
    if (isDispatching) {
      if (toAddHead == null) {
        toAddHead = toAddTail = listener;
      } else {
        toAddHead.next = listener;
        listener.previous = toAddHead;
        toAddTail = listener;
      }
    } else {
      if (head == null || tail == null) {
        head = tail = listener;
      } else {
        tail.next = listener;
        listener.previous = tail;
        tail = listener;
      }
    }

    return listener;
  }

  public function dispose() {
    if (isDisposed) return;
    isDisposed = true;

    var listener = head;

    while (listener != null) {
      listener.event = null;
      listener = listener.next;
    }

    head = null;
    tail = null;
    toAddHead = null;
    toAddTail = null;
  }

  public function trigger(value:T) {
    if (isDispatching) {
      Debug.error('Event is already dispatching');
    }

    isDispatching = true;
    var context = new EventContext(value);
    var listener = head;

    while (listener != null) {
      listener.handle(context);
      if (listener.once) listener.dispose();
      if (context.isPropagationStopped()) break;
      listener = listener.next;
    }
    
    isDispatching = false;

    if (toAddHead != null) {
      if (head == null || tail == null) {
        head = toAddHead;
        tail = toAddTail;
      } else {
        tail.next = toAddHead;
        toAddHead.previous = tail;
        tail = toAddTail;
      }
      toAddHead = toAddTail = null;
    }
  }

  function removeListener(listener:EventListener<T>) {
    if (head == listener)
      head = head.next;
    if (tail == listener)
      tail = tail.previous;
    if (toAddHead == listener)
      toAddHead = toAddHead.next;
    if (toAddTail == listener)
      toAddTail = toAddTail.previous;
    if (listener.previous != null)
      listener.previous.next = listener.next;
    if (listener.next != null)
      listener.next.previous = listener.previous;
    listener.event = null;
  }
}

class EventContext<T> {
  var isStopped:Bool = false;
  public final value:T;

  public function new(value) {
    this.value = value;
  }

  public function isPropagationStopped() {
    return isStopped;
  }

  public function stopPropagation() {
    isStopped = true;
  }
}

private class EventListener<T> implements Disposable {
  public final handle:(context:EventContext<T>) -> Void;
  public final once:Bool;

  public var event:Null<Event<T>>;
  public var previous:Null<EventListener<T>>;
  public var next:Null<EventListener<T>>;

  public function new(event, handle, once) {
    this.event = event;
    this.handle = handle;
    this.once = once;
  }

  public function dispose() {
    if (event != null) {
      @:privateAccess event.removeListener(this);
      event = null;
    }
  }
}
