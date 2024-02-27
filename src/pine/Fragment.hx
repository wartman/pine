package pine;

import pine.signal.Observer;
import pine.signal.Signal;
import pine.debug.Debug;

@:forward
abstract Fragment(View) to View to Child {
  @:from
  public static inline function of(children:Children):Fragment {
    return new Fragment(children);
  }

  @:from
  public static inline function track(children:ReadOnlySignal<Children>):Fragment {
    return cast new TrackedFragment(children);
  }

  public inline function new(children:Children) {
    this = new StaticFragment(children);
  }
}

class StaticFragment extends View {
  final children:Children;
  
  var marker:Null<View> = null;
  
  public function new(children) {
    this.children = children;
  }

  function __initialize() {
    var adaptor = getAdaptor();

    marker = Placeholder.build();
    marker.mount(this, adaptor, slot);

    var previous = marker;
    for (index => child in children) {
      child.mount(this, adaptor, new FragmentSlot(this.slot.index, index, previous.getPrimitive()));
      previous = child;
    }
  }

  public function findNearestPrimitive():Dynamic {
    return getParent().findNearestPrimitive();
  }

  public function getPrimitive():Dynamic {
    assert(marker != null);
    if (children.length == 0) return marker.getPrimitive();
    return children[children.length - 1].getPrimitive();
  }

  function __updateSlot(previousSLot:Null<Slot>, newSlot:Null<Slot>) {
    if (newSlot == null) return;
    marker.setSlot(newSlot);
    var previous = marker;
    for (index => child in children) {
      child.setSlot(new FragmentSlot(newSlot.index, index, previous.getPrimitive()));
      previous = child;
    }
  }

  function __dispose() {
    marker?.dispose();
    for (child in children) child.dispose();
    children.resize(0);
  }
}

class TrackedFragment extends View {
  public static inline function of(children:ReadOnlySignal<Children>) {
    return new TrackedFragment(children);
  }

  final children:ReadOnlySignal<Children>;
  final owner:Owner = new Owner();
  
  var reconciler:Null<Reconciler> = null;
  var marker:Null<View> = null;
  
  public function new(children) {
    this.children = children;
  }

  public function findNearestPrimitive():Dynamic {
    return getParent().findNearestPrimitive();
  }

  public function getPrimitive():Dynamic {
    assert(marker != null);
    return reconciler?.last()?.getPrimitive() ?? marker.getPrimitive();
  }

  function __initialize() {
    var adaptor = getAdaptor();
    
    marker = Placeholder.build();
    reconciler = new Reconciler(this, adaptor, (index, previous) -> {
      new FragmentSlot(slot.index, index, previous ?? marker?.getPrimitive());
    });

    marker.mount(this, adaptor, slot);
    owner.own(() -> Observer.track(() -> reconciler.reconcile(children())));
  }

  function __updateSlot(previousSLot:Null<Slot>, newSlot:Null<Slot>) {
    if (newSlot == null) return;

    marker.setSlot(newSlot);

    var previous = marker;

    reconciler.each((index, child) -> {
      child.setSlot(new FragmentSlot(newSlot.index, index, previous.getPrimitive()));
      previous = child;
    });
  }

  function __dispose() {
    owner.dispose();
    marker?.dispose();
    marker = null;
    reconciler?.dispose();
    reconciler = null;
  }
}
