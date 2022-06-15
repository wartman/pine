package pine;

class Fragment extends Component {
  static final type = new UniqueId();

  final children:Array<Component>;

  public function new(props:{
    children:Array<Component>,
    ?key:Key
  }) {
    super(props.key);
    children = props.children;
  }

  public inline function getChildren() {
    return children;
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

class FragmentElement extends Element {
  var children:Array<Element> = [];
  var marker:Null<Element>;
  var fragment(get, never):Fragment;
  function get_fragment():Fragment return getComponent();

  public function new(fragment:Fragment) {
    super(fragment);
  }

  override function getObject():Dynamic {
    Debug.alwaysAssert(root != null);

    var child:Null<Element> = null;

    visitChildren(c -> child = c);

    if (child == null) {
      if (marker == null) {
        marker = createElementForComponent(root.createPlaceholder(), slot);
      }
      return marker.getObject();
    }

    return child.getObject();
  }

  public function performBuild(previousComponent:Null<Component>) {
    if (previousComponent == null) {
      initializeChildren();
    } else {
      rebuildChildren();
    }
  }

  public function visitChildren(visitor:ElementVisitor) {
    if (children != null) {
      for (child in children)
        if (child != null)
          visitor.visit(child);
    }
  }

  function initializeChildren() {
    var components = fragment.getChildren();
    var previous:Null<Element> = slot != null ? slot.previous : null;
    var children:Array<Element> = [];

    for (i in 0...components.length) {
      var element = createElementForComponent(components[i], createSlotForChild(i, previous));
      children.push(element);
      previous = element;
    }

    this.children = children;
  }

  function performHydrate(cursor:HydrationCursor) {
    Debug.alwaysAssert(root != null);

    var components = fragment.getChildren();
    var previous:Null<Element> = slot != null ? slot.previous : null;
    var children:Array<Element> = [];

    if (components.length == 0) {
      marker = createElementForComponent(root.createPlaceholder(), slot);
      return;
    }

    for (i in 0...components.length) {
      var element = hydrateElementForComponent(cursor, components[i], createSlotForChild(i, previous));
      children.push(element);
      previous = element;
    }

    this.children = children;
  }

  function rebuildChildren() {
    Debug.alwaysAssert(root != null);

    var components = fragment.getChildren();
    children = diffChildren(children, components);

    // @todo: Test to make sure this is a good idea.
    if (children.length > 0 && marker != null) {
      marker.dispose();
      marker = null;
    }
  }

  override function updateSlot(slot:Slot) {
    Debug.alwaysAssert(root != null);

    this.slot = slot;
    if (marker != null)
      marker.updateSlot(slot);
    for (i in 0...children.length) {
      var previous = i == 0 ? slot.previous : children[i - 1];
      children[i].updateSlot(createSlotForChild(i, previous));
    }
  }

  override function createSlotForChild(localIndex:Int, previous:Null<Element>):Slot {
    var index = slot != null ? slot.index : 0;
    return new FragmentSlot(index, localIndex, previous);
  }

  override function dispose() {
    if (marker != null) {
      marker.dispose();
      marker = null;
    }
    super.dispose();
  }
}
