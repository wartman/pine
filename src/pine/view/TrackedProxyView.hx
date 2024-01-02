package pine.view;

import pine.signal.*;

class TrackedProxyView extends View {
  final link:Disposable;
  
  var child:Null<View> = null;
  
  public function new(parent, adaptor, slot, render:(context:Context)->Builder) {
    super(parent, adaptor, slot);
    link = new Observer(() -> {
      child?.dispose();
      child = render(this).createView(this, this.slot);
    });
  }

  public function findNearestPrimitive():Dynamic {
    return parent.findNearestPrimitive();
  }

  public function getPrimitive():Dynamic {
    return child.getPrimitive();
  }

  public function getSlot():Null<Slot> {
    return child.getSlot();
  }

  public function setSlot(slot:Null<Slot>) {
    this.slot = slot;
    child.setSlot(slot);
  }

  public function dispose() {
    link.dispose();
    child.dispose();
  }
}
