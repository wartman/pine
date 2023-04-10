package pine;

import kit.Assert;
import pine.signal.*;

abstract class ProxyComponent extends Component {
  var child:Null<Component> = null;

  abstract function build():Component;

  function initialize() {
    Observer.untrack(() -> {
      assert(status != Building);
      assert(status != Disposed);
      assert(child == null);
      
      if (status == Disposing) return;

      status = Building;
      child = build();
      if (child == null) child = new Placeholder();
      child.mount(this, slot);
      status = Valid;
    });
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
