package pine;

@component(ObjectComponent)
abstract class ObjectElement extends Element {
  var object:Null<Dynamic> = null;

  @:isVar var applicator(get, null):Null<ObjectApplicator<Dynamic>>;
  function get_applicator():ObjectApplicator<Dynamic> {
    if (this.applicator == null) { 
      this.applicator = objectComponent.getApplicator(this);
    }
    return this.applicator;
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
