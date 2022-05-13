package pine;

abstract class ObjectElement extends Element {
  var object:Null<Dynamic> = null;
  var objectComponent(get, never):ObjectComponent;

  inline function get_objectComponent():ObjectComponent {
    return cast component;
  }

  override function getObject():Dynamic {
    Debug.alwaysAssert(object != null);
    return object;
  }

  public function createObject():Dynamic {
    return objectComponent.createObject(getRoot());
  }

  public function updateObject(?oldComponent:Component) {
    Debug.alwaysAssert(object != null);
    objectComponent.updateObject(getRoot(), object, oldComponent);
  }
}
