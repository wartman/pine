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
    var children = reconciler?.getCurrentChildren();

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

    // @todo: There may be a more efficient way to iterate
    // over all of this?
    link = new Observer(() -> {
      var items = items();

      for (item => _ in itemToViewsMap) {
        if (!items.contains(item)) {
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
    var children = reconciler?.getCurrentChildren() ?? [];
    
    for (index => child in children) {
      child.setSlot(new FragmentSlot(newSlot.index, index, previous.getPrimitive()));
      previous = child;
    }
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
