package pine;

import pine.debug.Debug;
import pine.signal.Signal;
import pine.signal.Observer;
import pine.signal.Computation;

using Lambda;

// @:todo Uncertain if this flexibility is worth the complexity.
@:forward
abstract ForIterator<T>(ReadOnlySignal<Iterable<T>>) 
  from Signal<Iterable<T>>
  from Computation<Iterable<T>>
  from ReadOnlySignal<Iterable<T>> 
{
  @:from public static inline function ofArray<T>(arr:Array<T>):ForIterator<T> {
    return (arr:Iterable<T>);
  }

  @:from public static inline function ofSignalArray<T>(arr:Signal<Array<T>>):ForIterator<T> {
    return cast arr;
  }

  @:from public static inline function ofReadOnlySignalArray<T>(arr:ReadOnlySignal<Array<T>>):ForIterator<T> {
    return cast arr;
  }

  @:from public static inline function ofComputationArray<T>(arr:Computation<Array<T>>):ForIterator<T> {
    return cast arr;
  }

  @:op(a())
  public inline function get() {
    return this.get();
  }
}

class For<T:{}> extends View {
  @:fromMarkup
  @:noCompletion
  @:noUsing
  public inline static function fromMarkup<T:{}>(props:{
    public final each:ForIterator<T>;
    @:children public final child:(item:T)->Child;
  }) {
    return For.each(props.each, props.child);
  }

  public static inline function each<T:{}>(items, render) {
    return new For<T>(items, render);
  }

  final items:ForIterator<T>;
  final render:(item:T)->Child;
  final itemToViewsMap:Map<T, View> = [];
  
  var reconciler:Null<Reconciler> = null;
  var link:Null<Disposable> = null;
  var marker:Null<View> = null;

  public function new(items, render) {
    this.items = items;
    this.render = render;
  }

  public function findNearestPrimitive():Dynamic {
    return ensureParent().findNearestPrimitive();
  }

  public function getPrimitive():Dynamic {
    assert(marker != null);
    return reconciler?.last()?.getPrimitive() ?? marker.getPrimitive();
  }

  function __initialize() {
    marker = new Placeholder();
    reconciler = new Reconciler(this, getAdaptor(), (index, previous) -> {
      new FragmentSlot(slot.index, index, previous ?? marker?.getPrimitive());
    });

    marker.mount(this, getAdaptor(), slot);

    // @todo: There may be a more efficient way to iterate
    // over all of this?
    link = new Observer(() -> {
      var items = items();

      for (item => _ in itemToViewsMap) {
        if (!items.has(item)) {
          itemToViewsMap.remove(item);
        }
      }

      var next:Array<View> = [];

      for (item in items) {
        var view = itemToViewsMap.get(item);
        if (view == null) {
          view = render(item);
          itemToViewsMap.set(item, view);
        }
        next.push(view);
      }

      reconciler.reconcile(next);
    });
  }

  function __updateSlot(previousSlot:Null<Slot>, newSlot:Null<Slot>) {
    if (newSlot == null) return;
    marker.setSlot(newSlot);
    
    var previous = marker;

    reconciler.each((index, child) -> {
      child.setSlot(new FragmentSlot(newSlot.index, index, previous.getPrimitive()));
      previous = child;
    });
  }

  function __dispose() {
    link?.dispose();
    link = null;
    marker?.dispose();
    marker = null;
    reconciler?.dispose();
    reconciler = null;
  }
}
