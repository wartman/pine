package impl;

import pine.render.BaseObjectApplicator;

class TestingApplicator extends BaseObjectApplicator<TextComponent> {
  public function create(component:TextComponent):Dynamic {
    var obj = new TestingObject(component.content);
    if (component.ref != null) {
      component.ref(obj);
    }
    return obj;
  }

  public function update(object:Dynamic, component:TextComponent, ?previousComponent:TextComponent) {
    (object : TestingObject).content = component.content;
    return object;
  }
}
