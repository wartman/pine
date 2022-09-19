package pine;

abstract class ObjectElement extends Element {
  var object:Null<Dynamic> = null;
  
  var objectComponent(get, never):ObjectComponent;
  inline function get_objectComponent():ObjectComponent {
    return getComponent();
  }

  @:isVar var applicator(get, null):Null<ObjectApplicator<Dynamic>>;
  function get_applicator():ObjectApplicator<Dynamic> {
    if (this.applicator == null) this.applicator = objectComponent.getApplicator(this);
    return this.applicator;
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
    this.applicator = null;
  }

  override function updateSlot(slot:Slot) {
    Debug.alwaysAssert(object != null);

    var previousSlot = this.slot;
    this.slot = slot;

    applicator.move(object, previousSlot, slot, findAncestorObject);
  }
}
