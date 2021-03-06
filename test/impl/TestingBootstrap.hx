package impl;

import pine.Component;
import impl.TestingRootComponent;

class TestingBootstrap {
  final object:TestingObject;

  public function new(?object) {
    this.object = object == null ? new TestingObject('') : object;
  }

  public function mount(child:Component):TestingRootElement {
    var root = new TestingRootComponent({object: object, child: child});
    var el:TestingRootElement = cast root.createElement();
    el.bootstrap();
    return el;
  }
}
