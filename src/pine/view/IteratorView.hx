package pine.view;

import pine.signal.Observer;
import pine.signal.Signal;

class IteratorView<T:{}> extends View {
  final items:ReadOnlySignal<Array<T>>;
  final render:(item:T, context:Context)->ViewBuilder;
  final marker:View;
  final itemToViewsMap:Map<T, View> = [];
  final link:Disposable;

  var children:Null<Array<View>> = null;

  public function new(parent, adaptor, slot, items, render) {
    super(parent, adaptor, slot);

    this.render = render;
    this.items = items;
    this.marker = Placeholder.build().createView(this, slot);

    link = new Observer(() -> {
      var items = items();

      for (item => child in itemToViewsMap) {
        if (!items.contains(item)) {
          itemToViewsMap.remove(item);
          child.dispose();
        }
      }

      var next:Array<View> = [];
      var previous:View = this.marker;

      for (index => item in items) {
        var view = itemToViewsMap.get(item);
        if (view == null) {
          view = render(item, this).createView(this, new IteratorSlot(this.slot.index, index, previous.getPrimitive()));
          itemToViewsMap.set(item, view);
        } else {
          view.setSlot(new IteratorSlot(this.slot.index, index, previous.getPrimitive()));
        }
        next.push(view);
        previous = view;
      }

      children = next;
    });
  }

  public function findNearestPrimitive():Dynamic {
    return parent.findNearestPrimitive();
  }

  public function getPrimitive():Dynamic {
    if (children.length == 0) return marker.getPrimitive();
    return children[children.length - 1].getPrimitive();
  }

  public function getSlot():Null<Slot> {
    return slot;
  }

  public function setSlot(slot:Null<Slot>) {
    this.slot = slot;

    if (this.slot == null) return;

    marker.setSlot(slot);
    var previous = marker;
    for (index => child in children) {
      child.setSlot(new IteratorSlot(slot.index, index, previous.getPrimitive()));
      previous = child;
    }
  }

  public function dispose() {
    link.dispose();
    marker.dispose();
    if (children != null) for (child in children) child.dispose();
    children = null;
  }
}

class IteratorSlot extends Slot {
  public final localIndex:Int;

  public function new(index, localIndex, previous) {
    super(index, previous);
    this.localIndex = localIndex;
  }

  override function indexChanged(other:Slot):Bool {
    if (other.index != index)
      return true;
    if (other is IteratorSlot) {
      var otherFragment:IteratorSlot = cast other;
      return localIndex != otherFragment.localIndex;
    }
    return false;
  }
}
