package pine;

class Portal implements ViewBuilder {
  @:fromMarkup
  @:noCompletion
  public inline static function fromMarkup(props:{
    public final target:Dynamic;
    @:children public final child:Child;
  }) {
    return new Portal(props.target, props.child);
  }

  public inline static function into(target, render) {
    return new Portal(target, render);
  }

  final target:Dynamic;
  final child:Child;

  public function new(target, child) {
    this.target = target;
    this.child = child;
  }
  
  public function createView(parent:View, slot:Null<Slot>):View {
    return new PortalView(parent, parent.adaptor, slot, target, child);
  }
}

class PortalView extends View {
  var child:View;
  var root:View;

  public function new(parent, adaptor, slot, target, wrapped:Child) {
    super(parent, adaptor, slot);
    this.child = Placeholder.build().createView(this, slot);
    this.root = new Root(target, adaptor, _ -> wrapped).create(this);
  }
  
  public function findNearestPrimitive():Dynamic {
    return child.getPrimitive();
  }

  public function getPrimitive():Dynamic {
    return child.getPrimitive();
  }

  public function getSlot():Null<Slot> {
    return slot;
  }

  public function setSlot(slot:Null<Slot>) {
    this.slot = slot;
    child.setSlot(slot);
  }
  
  public function dispose() {
    root.dispose();
    child.dispose();
  }
}
