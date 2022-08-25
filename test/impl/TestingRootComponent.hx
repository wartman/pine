package impl;

import pine.*;
import pine.render.*;
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

  override function updateObject(root:Root, object:Dynamic, ?previousComponent:Component) {
    return object;
  }

  public function getRootObject():Dynamic {
    return object;
  }

  public function getApplicatorType():UniqueId {
    return TextComponent.type;
  }
}

class TestingRootElement extends RootElement {
  public final afterBuild:Queue = new Queue();

  public function new(root) {
    super(
      root,
      new ObjectApplicatorCollection([TextComponent.type => new TestingApplicator()]),
      (target, ?child) -> new TestingRootComponent({ child: child, object: target })
    );
  }

  public function setChild(component:ObjectComponent, ?next:() -> Void) {
    var prev:TestingRootComponent = cast this.component;

    this.component = new TestingRootComponent({
      object: prev.object,
      child: prev.child
    });

    if (next != null) {
      afterBuild.enqueue(next);
    }

    invalidate();
  }

  override function performBuild(previousComponent:Null<Component>) {
    super.performBuild(previousComponent);
    afterBuild.dequeue();
  }

  public function toString() {
    return (getObject() : TestingObject).toString();
  }

  public function createPlaceholder() {
    return new TextComponent({ content: '<marker>' });
  }
}
