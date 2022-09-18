package pine;

abstract class ObjectElement extends Element {
  var currentApplicator:Null<ObjectApplicator<Dynamic>> = null;
  var object:Null<Dynamic> = null;
  
  var objectComponent(get, never):ObjectComponent;
  inline function get_objectComponent():ObjectComponent {
    return getComponent();
  }

  var applicator(get, never):ObjectApplicator<Dynamic>;
  function get_applicator():ObjectApplicator<Dynamic> {
    if (currentApplicator == null) currentApplicator = objectComponent.getApplicator(this);
    return currentApplicator;
  }

  public function new(component:ObjectComponent) {
    super(component);
  }

  override function getObject():Dynamic {
    Debug.alwaysAssert(object != null);
    return object;
  }

  override function dispose() {
    super.dispose();
    currentApplicator = null;
  }

  override function updateSlot(slot:Slot) {
    Debug.alwaysAssert(object != null);

    var previousSlot = this.slot;
    this.slot = slot;

    applicator.move(object, previousSlot, slot, findAncestorObject);
  }
}
