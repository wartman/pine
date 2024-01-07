package pine;

import pine.Disposable;
import pine.signal.Graph;
import pine.signal.Observer;
import pine.signal.Signal;

class Primitive implements ViewBuilder {
  final tag:String;
  final attributes:Map<String, ReadOnlySignal<Dynamic>> = [];
  final views:Children = [];
  final refCallback:Null<(primitive:Dynamic)->Void> = null;

  public function new(tag, attributes, views, refCallback) {
    this.tag = tag;
    this.attributes = attributes;
    this.views = views;
    this.refCallback = refCallback;
  }

  public function createView(parent:View, slot:Null<Slot>):View {
    return new PrimitiveView(
      parent,
      parent.adaptor,
      slot,
      tag,
      attributes,
      views,
      refCallback
    );
  }
}

class PrimitiveView extends View {
  final primitive:Dynamic;
  final disposables:DisposableCollection = new DisposableCollection();
  final attributes:Map<String, ReadOnlySignal<Dynamic>> = [];
  final children:Array<View>;
  
  public function new(
    parent, 
    adaptor,
    slot,
    tag,
    attributes,
    children:Array<ViewBuilder>,
    ref:Null<(primitive:Dynamic)->Void>
  ) {
    super(parent, adaptor, slot);
    
    this.primitive = adaptor.createPrimitive(tag);
    this.attributes = attributes;
    this.children = [];
  
    var previousOwner = setCurrentOwner(Some(disposables));

    for (name => value in attributes) Observer.track(() -> {
      adaptor.updatePrimitiveAttribute(primitive, name, value());
    });
    
    var previous:Null<View> = null;
    for (index => child in children) {
      var childView = child.createView(this, new Slot(index, previous?.getPrimitive()));
      this.children.push(childView);
      previous = childView;
    }

    setCurrentOwner(previousOwner);

    if (ref != null) ref(primitive);

    adaptor.insertPrimitive(primitive, slot, parent.findNearestPrimitive);
  }

  public function getSlot() {
    return slot;
  }

  public function setSlot(slot:Null<Slot>) {
    var prevSlot = this.slot;
    this.slot = slot;
    adaptor.movePrimitive(primitive, prevSlot, slot, parent.findNearestPrimitive);
  }

  public function findNearestPrimitive():Dynamic {
    return primitive;
  }

  public function getPrimitive():Dynamic {
    return primitive;
  }

  public function dispose() {
    adaptor.removePrimitive(primitive, slot);
    disposables.dispose();
    for (child in children) child.dispose();
  }
}
