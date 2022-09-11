package impl;

import pine.*;
import pine.RootComponent;

class TestingRootComponent extends RootComponent {
  public static final type:UniqueId = new UniqueId();

  public final object:TestingObject;

  public function new(props:{ ?child:Component, object:TestingObject }) {
    super(props);
    object = props.object;
  }

  public function getComponentType():UniqueId {
    return type;
  }

  function createElement():Element {
    return new TestingRootElement(this);
  }

  public function getRootObject():Dynamic {
    return object;
  }

  public function getApplicatorType():UniqueId {
    return TextComponent.type;
  }
}

class TestingProcess extends Process {
  function nextFrame(exec:() -> Void) {
    haxe.Timer.delay(() -> exec(), 10);
  }
}

class TestingAdaptor extends Adapter {
  static final applicator = new TestingApplicator();
  static final process = new TestingProcess();

  public function new() {}

  public function getApplicator(component:ObjectComponent):ObjectApplicator<Dynamic> {
    return applicator;
  }
  
  public function getTextApplicator(component:ObjectComponent):ObjectApplicator<Dynamic> {
    return applicator;
  }

  public function getProcess():Process {
    return process;
  }

  public function createPlaceholder():Component {
    return new TextComponent({ content: '<marker>' });
  }

  public function createPortalRoot(target:Dynamic, ?child:Component):RootComponent {
    return new TestingRootComponent({ object: target, child: child });
  }
}

class TestingRootElement extends RootElement {
  public final afterBuild:Array<()->Void> = [];

  public function new(root) {
    super(root, new TestingAdaptor());
  }

  public function setChild(component:ObjectComponent, ?next:() -> Void) {
    var prev:TestingRootComponent = cast this.component;

    this.component = new TestingRootComponent({
      object: prev.object,
      child: prev.child
    });

    if (next != null) {
      afterBuild.push(next);
    }

    invalidate();
  }

  override function performBuild(previousComponent:Null<Component>) {
    super.performBuild(previousComponent);
    var effect = afterBuild.pop();
    while (effect != null) {
      effect();
      effect = afterBuild.pop();
    }
  }

  public function toString() {
    return (getObject() : TestingObject).toString();
  }
}
