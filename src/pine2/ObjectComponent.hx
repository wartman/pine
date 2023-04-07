package pine2;

import kit.Assert;
import pine2.internal.ObjectHost;
import pine2.internal.Render;
import pine2.signal.*;

abstract class ObjectComponent extends Component implements ObjectHost {
  var object:Null<Dynamic> = null;
  
  public function initialize() {
    initializeObject();
    status = Valid;
  }

  function getObject():Dynamic {
    return object;
  }

  override function updateSlot(?newSlot:Slot) {
    if (slot == newSlot) return;
    var prevSlot = slot;
    super.updateSlot(newSlot);
    getAdaptor()?.moveObject(getObject(), prevSlot, slot, () -> null /* todo */);
  }
}

abstract class ElementComponent extends ObjectComponent {
  final children:Signal<Array<Component>>;

  public function new(children) {
    this.children = children;
  }

  abstract function getName():String;
  abstract function getInitialAttrs():{};
  abstract function observeAttributeChanges():Void;

  function initializeObject() {
    object = adaptor?.createElementObject(getName(), getInitialAttrs());
    adaptor?.insertObject(object, slot, findNearestObjectHostAncestor);
    observeAttributeChanges();

    var prevChildren:Array<Component> = [];
    var childrenObserver = new Observer(() -> {
      assert(status != Building);
      assert(status != Disposing);
      assert(status != Disposed);

      status = Building;
      prevChildren = reconcileChildren(this, prevChildren, children.get());
      status = Valid;
    });
    addDisposable(childrenObserver);
  }

  public function visitChildren(visitor:(child:Component) -> Bool) {
    for (child in children.peek()) if (!visitor(child)) break;
  }
}
