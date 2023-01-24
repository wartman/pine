package pine;

import pine.ObjectComponent;
import pine.adaptor.Adaptor;
import pine.adaptor.ObjectType;
import pine.diffing.Key;

abstract class RootComponent extends ObjectComponent {
  public final child:Component;

  public function new(props:{
    child:Component,
    ?key:Key
  }) {
    this.child = props.child;
    super(props.key);
  }

  public function getObjectType():ObjectType {
    return ObjectRoot;
  }

  abstract public function getRootObject():Dynamic;

  abstract public function createAdaptor():Adaptor;

  public function render() {
    return [ child ];
  }

  override function createElement() {
    return new Element(this, useObjectElementEngine(
      (element:ElementOf<RootComponent>) -> element.component.render(),
      {
        createObject: (_, element) -> element.component.getRootObject(),
        destroyObject: (applicator, element, object) -> null,
        findAdaptor: element -> element.component.createAdaptor()
      }
    ));
  }
}
