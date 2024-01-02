package pine.view;

import pine.Disposable;
import pine.signal.Graph;

class UntrackedProxyView extends View {
  final child:View;
  final disposables = new DisposableCollection();
  
  public function new(parent, adaptor, slot, render:(context:Context)->ViewBuilder) {
    super(parent, adaptor, slot);
    child = withOwnedValue(disposables, () -> {
      untrackValue(() -> render(this).createView(this, this.slot));
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
    disposables.dispose();
    child.dispose();
  }
}
