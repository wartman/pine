package pine;

class Fragment extends Component {
  static final type = new UniqueId();

  final children:Array<Null<Component>>;

  public function new(props:{
    children:Array<Component>,
    ?key:Key
  }) {
    super(props.key);
    children = props.children;
  }

  public inline function getChildren():Array<Component> {
    return cast children.filter(c -> c != null);
  }

  public function getComponentType():UniqueId {
    return type;
  }

  public function createElement():Element {
    return new FragmentElement(this);
  }
}

class FragmentSlot extends Slot {
  public final localIndex:Int;

  public function new(index, localIndex, previous) {
    super(index, previous);
    this.localIndex = localIndex;
  }

  override function indexChanged(other:Slot):Bool {
    if (other.index != index)
      return true;
    if (other is FragmentSlot) {
      var otherFragment:FragmentSlot = cast other;
      return localIndex != otherFragment.localIndex;
    }
    return false;
  }
}

class FragmentSlotFactory implements SlotFactory {
  final element:FragmentElement;

  public function new(element) {
    this.element = element;
  }

  public function create(localIndex:Int, previous:Null<Element>):Slot {
    var index = element.slot == null ? 0 : element.slot.index;
    return new FragmentSlot(index, localIndex, previous);
  }
}

private class FragmentChildren extends MultipleChildren {
  public var marker:Null<Element> = null;
  final element:FragmentElement;

  public function new(element, elements, slots) {
    this.element = element;
    super(
      () -> element.fragment.getChildren(),
      elements,
      slots
    );
  }

  override function initPrevious(?slot:Slot):Null<Element> {
    return slot != null ? slot.previous : null;
  }

  public function createMarker():Element {
    if (marker == null) {
      marker = elements.create(Adapter.from(element).createPlaceholder(), element.slot);
    }
    return marker;
  }

  override function hydrate(cursor:HydrationCursor, ?slot:Slot) {
    var components = renderSafe();

    if (components.length == 0) {
      createMarker();
      return;
    }

    super.hydrate(cursor, slot);
  }

  override function rebuildChildren(?slot:Slot) {
    super.rebuildChildren(slot);
    // @todo: Test to make sure this is a good idea.
    if (children.length > 0 && marker != null) {
      marker.dispose();
      marker = null;
    }
  }

  public function updateChildSlots(?slot:Slot) {
    if (marker != null) {
      marker.updateSlot(slot);
    }

    if (slot == null) slot = new Slot(0, null);

    for (i in 0...children.length) {
      var previous = i == 0 ? slot.previous : children[i - 1];
      children[i].updateSlot(slots.create(i, previous));
    }
  }

  override function dispose() {
    if (marker != null) {
      marker.dispose();
      marker = null;
    }
    super.dispose();
  }
}

private class FragmentElement extends Element {
  public var fragment(get, never):Fragment;
  function get_fragment():Fragment return getComponent();

  final children:FragmentChildren;

  public function new(fragment:Fragment) {
    super(fragment);
    children = new FragmentChildren(
      this, 
      new DefaultElementFactory(this),
      new FragmentSlotFactory(this)  
    );
  }

  override function getObject():Dynamic {
    var child:Null<Element> = null;

    children.visit(c -> child = c);

    if (child == null) {
      return children.createMarker().getObject();
    }

    return child.getObject();
  }

  function performHydrate(cursor:HydrationCursor) {
    children.hydrate(cursor, slot);
  }

  function performBuild(previousComponent:Null<Component>) {
    children.update(previousComponent, slot);
  }

  function performDispose() {
    children.dispose();
  }

  function performUpdateSlot(?slot:Slot) {
    children.updateChildSlots(slot);    
  }

  public function visitChildren(visitor:ElementVisitor) {
    children.visit(visitor);
  }
}
