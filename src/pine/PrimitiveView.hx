package pine;

import pine.Disposable;
import pine.signal.Observer;
import pine.signal.Signal;

class PrimitiveView extends View {
  final tag:String;
  final children:Children;
  final attributes:Map<String, ReadOnlySignal<Dynamic>> = [];
  final ref:Null<(primitive:Dynamic)->Void>;
  final owner:Owner = new Owner();

  var primitive:Null<Dynamic> = null;
  
  public function new(tag, attributes, children:Children, ?ref) {
    this.tag = tag;
    this.attributes = attributes;
    this.children = children;
    this.ref = ref;
  }

  function __initialize() {
    var adaptor = getAdaptor();
    var parent = ensureParent();

    this.primitive = adaptor.createPrimitive(tag, slot, parent.findNearestPrimitive);
    
    owner.own(() -> {
      for (name => value in attributes) Observer.track(() -> {
        adaptor.updatePrimitiveAttribute(primitive, name, value());
      });
      
      var previous:Null<View> = null;
      for (index => child in children) {
        child.mount(this, adaptor, new Slot(index, previous?.getPrimitive()));
        previous = child;
      }
    });

    if (ref != null) ref(primitive);

    adaptor.insertPrimitive(primitive, slot, parent.findNearestPrimitive);
  }
  
  public function findNearestPrimitive():Dynamic {
    return primitive;
  }

  public function getPrimitive():Dynamic {
    return primitive;
  }

  function __updateSlot(previousSlot:Null<Slot>, newSlot:Null<Slot>) {
    getAdaptor().movePrimitive(primitive, previousSlot, newSlot, ensureParent().findNearestPrimitive);
  }

  function __dispose() {
    getAdaptor().removePrimitive(primitive, slot);
    owner.dispose();
    for (child in children) child.dispose();
  }
}
