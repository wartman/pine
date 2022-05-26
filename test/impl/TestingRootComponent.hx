package impl;

import pine.*;
import pine.render.*;
import pine.RootComponent;

class TestingRootComponent extends RootComponent {
  public static final type:UniqueId = new UniqueId();

  public final object:TestingObject;

  public function new(props) {
    object = props.object;
    super(props);
  }

  public function getComponentType():UniqueId {
    return type;
  }

  function createElement():Element {
    return new TestingRootElement(this);
  }

  public function updateObject(root:Root, object:Dynamic, ?previousComponent:Component) {
    return object;
  }

  public function getRootObject():Dynamic {
    return object;
  }
}

class TestingRootElement extends ObjectRootElement {
  var queue:Null<Array<() -> Void>> = null;

  public function setChild(component:ObjectComponent, ?next:() -> Void) {
    var prev:TestingRootComponent = cast this.component;

    this.component = new TestingRootComponent({
      object: prev.object,
      child: prev.child
    });

    if (next != null) {
      if (queue == null) queue = [];
      queue.push(next);
    }

    invalidate();
  }

  override function performBuild(previousComponent:Null<Component>) {
    super.performBuild(previousComponent);
    if (queue != null) {
      for (fx in queue) fx();
      queue = null;
    }
  }

  public function toString() {
    return (getObject() : TestingObject).toString();
  }

  public function createPlaceholderObject(component:Component):Dynamic {
    return new TestingObject('<marker>');
  }
}
