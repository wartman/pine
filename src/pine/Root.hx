package pine;

import pine.signal.Observer;

class Root {
  public inline static function build(target:Dynamic, adaptor, render) {
    return new Root(target, adaptor, render);
  }

  final target:Dynamic;
  final adaptor:Adaptor;
  final render:()->Child;

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

private class RootView extends View {
  final target:Dynamic;
  final render:()->Child;
  final hydrate:Bool;

  var link:Null<Disposable> = null;
  var child:Null<View> = null;

  public function new(parent, adaptor, target, render, hydrate = false) {
    this.target = target;
    this.hydrate = hydrate;
    this.render = render;

    mount(parent, adaptor, new Slot(0, null));
  }

  function __initialize() {
    var parent = getParent();
    var adaptor = getAdaptor();
    var doRender = () -> {
      child?.dispose();
      child = render();
      child.mount(this, adaptor, slot);
    };

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

  function __updateSlot(previousSlot:Null<Slot>, newSlot:Null<Slot>) {}

  function __dispose() {
    child?.dispose();
    child = null;
    link?.dispose();
    link = null;
  }
}
