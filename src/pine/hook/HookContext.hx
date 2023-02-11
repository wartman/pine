package pine.hook;

import pine.debug.Debug;
import pine.core.Disposable;

enum HookContextStatus {
  Waiting;
  Init;
  Update(iterator:HookIterator);
  Disposed;
}

// @todo: Maybe merge HookList into HookContext to simplify things.
class HookContext<T:Component> implements Disposable {
  public inline static function from<T:Component>(element:ElementOf<T>):HookContext<T> {
    return cast element.getHooks();
  }

  final list:HookList = new HookList();
  final element:ElementOf<T>;

  var status:HookContextStatus = Init;

  public function new(element) {
    this.element = element;
    element.events.beforeInit.add((_, _) -> setStatus(Init));
    element.events.beforeUpdate.add((_, _, _) -> setStatus(Update(list.iterator())));
    element.events.afterInit.add((_, _) -> cleanup());
    element.events.afterUpdate.add((_) -> cleanup());
    element.events.beforeDispose.add(_ -> dispose());
  }

  public function use<T:HookState<R>, R>(
    value:R,
    createState:(value:R)->T
  ):T {
    return switch status {
      case Init:
        var state = createState(value);
        list.add(state);
        state;
      case Update(iterator) if (iterator.hasNext()):
        var state = iterator.next();
        state.update(value);
        return cast state;
      case Update(_):
        Debug.error(
          'Too many hooks were encountered on a component update. Hooks should'
          + ' never be wrapped in conditionals, loops or functions -- they'
          + ' should only be registered when a component is rendering.'
        );
      case Disposed:
        Debug.error('Cannot add a hook to a disposed context');
      case Waiting:
        Debug.error('A hook was added in the wrong place.');
    }
  }

  public function dispose() {
    status = Disposed;
    list.dispose();
  }

  inline function cleanup() {
    #if debug
    switch status {
      case Update(iterator): 
        // @todo: better error handling
        Debug.assert(iterator.hasNext() == false, 'Too few hooks');
      default:
    }
    #end
    setStatus(Waiting);
  }

  inline function setStatus(newStatus:HookContextStatus) {
    Debug.assert(status != Disposed);
    status = newStatus;
  }
}

@:allow(pine.hook)
private class HookList implements Disposable {
  public var length(default, null):Int = 0;

  var head:Null<HookNode> = null;
  var tail:Null<HookNode> = null;
  
  public function new() {}

  public function add(state:HookState<Dynamic>) {
    var node:HookNode = { next: null, state: state };
    if (head == null) {
      head = node;
    } else if (tail != null) {
      tail.next = node;
    }
    tail = node;
    length++;
  }

  public inline function iterator() {
    return new HookIterator(this);
  }

  public function dispose() {
    for (node in this) node.dispose();
    head = null;
    tail = null;
    length = 0;
  }
}

private typedef HookNode = {
  public var next:Null<HookNode>;
  public final state:HookState<Dynamic>;
}

private class HookIterator {
  final list:HookList;
  var current:Null<HookNode>;

  public function new(list) {
    this.list = list;
    this.current = list.head;
  }

  public function hasNext() {
    return current != null;
  }

  public function next() {
    Debug.assert(current != null);
    var value = current.state;
    current = current.next;
    return value;
  }
}

