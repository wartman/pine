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

	public function getApplicatorType():UniqueId {
    return type;
	}
}
