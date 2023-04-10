package pine2;

import kit.Assert;
import pine2.signal.*;

abstract class ProxyComponent extends Component {
  var child:Null<Component> = null;

  abstract function build():Component;

  function initialize() {
    var observer = new Observer(() -> {
      assert(status != Building);
      assert(status != Disposed);
      
      if (status == Disposing) return;

      status = Building;
      if (child != null) child.dispose();
      child = build();
      if (child == null) child = new Placeholder();
      child.mount(this, slot);
      status = Valid;
    });
    addDisposable(observer);
  }

  function getObject():Dynamic {
    var object:Null<Dynamic> = null;
      
    visitChildren(child -> {
      if (object != null) {
        throw new PineException('Component has more than one objects');
      }
      object = child.getObject();
      true;
    });

    if (object == null) {
      throw new PineException('Could not resolve an object');
    }

    return object;
  }

  override function updateSlot(?newSlot:Slot) {
    super.updateSlot(newSlot);
    visitChildren(child -> {
      child.updateSlot(newSlot);
      true;
    });
  }

  function visitChildren(visitor:(child:Component)->Bool) {
    if (child != null) visitor(child);
  }
}
