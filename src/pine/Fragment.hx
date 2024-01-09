package pine;

import pine.view.IteratorView.IteratorSlot;

class Fragment implements ViewBuilder {
  public inline static function of(children) {
    return new Fragment(children);
  }

  public inline static function empty() {
    return new Fragment([]);
  }

  var children:Children;

  public function new(children) {
    this.children = children;
  }

  public function append(...child:ViewBuilder) {
    children = children.concat(child.toArray());
    return this;
  }

  public function createView(parent:View, slot:Null<Slot>):View {
    return new FragmentView(parent, parent.adaptor, slot, children);
  }
}

class FragmentView extends View {
  final children:Array<ViewBuilder>;
  final marker:View;
  
  var views:Array<View> = [];
  
  public function new(parent, adaptor, slot, children) {
    super(parent, adaptor, slot);
    this.children = children;
    this.marker = Placeholder.build().createView(this, slot);

    var previous = marker;

    for (index => child in children) {
      var view = child.createView(this, new IteratorSlot(this.slot.index, index, previous.getPrimitive()));
      views.push(view);
      previous = view;
    }
  }

  public function findNearestPrimitive():Dynamic {
    return parent.findNearestPrimitive();
  }

  public function getPrimitive():Dynamic {
    if (views.length == 0) return marker.getPrimitive();
    return views[views.length - 1].getPrimitive();
  }

  public function getSlot():Null<Slot> {
    return slot;
  }

  public function setSlot(slot:Null<Slot>) {
    this.slot = slot;

    if (this.slot == null) return;

    marker.setSlot(slot);
    var previous = marker;
    for (index => child in views) {
      child.setSlot(new IteratorSlot(slot.index, index, previous.getPrimitive()));
      previous = child;
    }
  }

  public function dispose() {
    marker.dispose();
    for (child in views) child.dispose();
    views = [];
  }
}
