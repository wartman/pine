package pine;

import pine.debug.Debug;
import pine.signal.Signal;
import pine.signal.Observer;

class For<T:{}> extends View {
  @:fromMarkup
  @:noCompletion
  public inline static function fromMarkup<T:{}>(props:{
    public final each:ReadOnlySignal<Array<T>>;
    @:children public final child:(item:T)->Child;
  }) {
    return For.each(props.each, props.child);
  }

  public static inline function each<T:{}>(items, render) {
    return new For<T>(items, render);
  }

  final items:ReadOnlySignal<Array<T>>;
  final render:(item:T)->Child;
  final itemToViewsMap:Map<T, View> = [];
  
  var children:Null<Array<View>> = null;
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
    assert(children != null);
    assert(marker != null);

    if (children.length == 0) return marker.getPrimitive();
    return children[children.length - 1].getPrimitive();
  }

  function __initialize() {
    marker = new Placeholder();
    reconciler = new Reconciler(this, getAdaptor(), (index, previous) -> {
      new FragmentSlot(slot.index, index, previous ?? marker?.getPrimitive());
    });

    marker.mount(this, getAdaptor(), slot);

    link = new Observer(() -> {
      var items = items();

      for (item => _ in itemToViewsMap) {
        if (!items.contains(item)) {
          itemToViewsMap.remove(item);
          // child.dispose();
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

      // I'm actually not sure if this reconciler is *faster* than
      // just looping over the map, but we'll use it.
      children = reconciler.reconcile(next);

      // var previous:View = this.marker;

      // for (index => item in items) {
      //   var view = itemToViewsMap.get(item);
      //   if (view == null) {
      //     view = render(item);
      //     view.mount(this, getAdaptor(), new FragmentSlot(this.slot.index, index, previous.getPrimitive()));
      //     itemToViewsMap.set(item, view);
      //   } else {
      //     view.setSlot(new FragmentSlot(this.slot.index, index, previous.getPrimitive()));
      //   }
      //   next.push(view);
      //   previous = view;
      // }

      // children = next;
    });
  }

  function __updateSlot(previousSlot:Null<Slot>, newSlot:Null<Slot>) {
    if (newSlot == null) return;
    marker.setSlot(newSlot);
    var previous = marker;
    for (index => child in children) {
      child.setSlot(new FragmentSlot(newSlot.index, index, previous.getPrimitive()));
      previous = child;
    }
  }

  function __dispose() {
    reconciler?.dispose();
    reconciler = null;
    link?.dispose();
    link = null;
    marker?.dispose();
    marker = null;
    if (children != null) for (child in children) child.dispose();
    children = null;
  }
}
