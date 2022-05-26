package notebook.framework;

import pine.*;

class Portal extends ObjectComponent {
  static final type = new UniqueId();

  final el:js.html.Element;
  final child:Component;
  
  public function new(props) {
    super(null);
    this.el = props.el;
    this.child = props.child;
  }

  public function getChildren():Array<Component> {
    return [ child ];
  }

  public function createObject(root:Root):Dynamic {
    return el;
  }

  public function getComponentType():UniqueId {
    return type;
  }

  public function updateObject(root:Root, object:Dynamic, ?previousComponent:Component):Dynamic {
    return object;
  }

  override function insertObject(root:Root, object:Dynamic, slot:Null<Slot>, findParent:() -> Dynamic) {
    // noop
  }

  override function removeObject(root:Root, object:Dynamic, slot:Null<Slot>) {
    // noop
  }

  override function moveObject(root:Root, object:Dynamic, from:Null<Slot>, to:Null<Slot>, findParent:() -> Dynamic) {
    // noop
  }

  public function createElement():Element {
    return new ObjectWithChildrenElement(this);
  }
}
