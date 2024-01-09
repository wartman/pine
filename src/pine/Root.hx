package pine;

import pine.signal.Observer;

class Root {
  public inline static function build(target:Dynamic, adaptor, render) {
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

  public function create(?parent):View {
    return new RootView(parent, adaptor, target, render);
  }

  public function hydrate(?parent):View {
    return new RootView(parent, adaptor, target, render, true);
  }
}

class RootView extends View {
  final target:Dynamic;

  var link:Null<Disposable> = null;
  var child:Null<View> = null;
  
  public function new(parent:Null<View>, adaptor, target, render:(context:Context)->ViewBuilder, hydrate = false) {
    super(parent, adaptor, new Slot(0, null));

    var doRender = () -> {
      child?.dispose();
      child = render(this).createView(this, this.slot);
    };

    this.target = target;

    if (hydrate) adaptor.hydrate(() -> {
      this.link = parent == null 
        ? Observer.root(doRender) 
        : Observer.track(doRender);
    }) else {
      this.link = parent == null 
        ? Observer.root(doRender) 
        : Observer.track(doRender);
    }
  }

  public function findNearestPrimitive():Dynamic {
    return target;
  }

  public function getPrimitive():Dynamic {
    return target;
  }

  public function getSlot():Null<Slot> {
    return slot;
  }

  public function setSlot(slot:Null<Slot>) {}

  public function dispose() {
    link?.dispose();
    child?.dispose();
  }
}
