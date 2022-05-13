package impl;

import pine.*;

class TextComponent extends ObjectComponent {
  public static final type = new UniqueId();

  public final content:String;
  public final ref:Null<(object:TestingObject) -> Void>;

  public function new(props:{content:String, ?ref:(object:TestingObject) -> Void, ?key:Key}) {
    super(props.key);
    this.content = props.content;
    this.ref = props.ref;
  }

  public function getComponentType():UniqueId {
    return type;
  }

  public function getChildren():Array<Component> {
    return [];
  }

  public function createElement() {
    return new ObjectWithoutChildrenElement(this);
  }

  public function createObject(root:Root):Dynamic {
    var obj = new TestingObject(content);
    if (ref != null)
      ref(obj);
    return obj;
  }

  public function updateObject(root:Root, object:Dynamic, ?previousComponent:Component):Dynamic {
    (object : TestingObject).content = content;
    return object;
  }
}
