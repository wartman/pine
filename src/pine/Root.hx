package pine;

import pine.signal.Observer;

class Root {
  public inline static function build(target, adaptor, render) {
    return new Root(target, adaptor, render);
  }

  final target:Dynamic;
  final adaptor:Adaptor;
  final render:(context:Context)->ViewBuilder;

  public function new(target, adaptor, render) {
    this.target = target;
    this.adaptor = adaptor;
    this.render = render;
  }

  public function create():View {
    return new RootView(adaptor, target, render);
  }
}

class RootView extends View {
  final target:Dynamic;
  final link:Disposable;

  var child:Null<View> = null;
  
  public function new(adaptor, target, render:(context:Context)->ViewBuilder) {
    super(null, adaptor, new Slot(0, null));
    this.target = target;
    this.link = Observer.root(() -> {
      child?.dispose();
      child = render(this).createView(this, this.slot);
    });
  }

  public function findNearestPrimitive():Dynamic {
    return target;
  }

  override function get<T>(type:Class<T>):Null<T> {
    return null;
  }

  public function getPrimitive():Dynamic {
    return target;
  }

  public function getSlot():Null<Slot> {
    return slot;
  }

  public function setSlot(slot:Null<Slot>) {}

  public function dispose() {
    link.dispose();
    child?.dispose();
  }
}
