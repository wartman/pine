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
}
