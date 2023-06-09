package pine;

import pine.debug.Debug;
import pine.internal.Reconcile;
import pine.internal.Slot;
import pine.signal.Observer;

class Fragment extends Component {
  var marker:Null<Component> = null;
  final children:Children;

  public function new(children) {
    this.children = children;
  }

  public function getObject():Dynamic {
    var currentChildren = children.peek();
    var currentLen = currentChildren.length;
    if (currentLen == 0) {
      var obj = marker?.getObject();
      if (obj == null) {
        error('No object found');
      }
      return obj;
    }
    return currentChildren[currentLen - 1].getObject();
  }

  public function initialize() {
    marker = new Placeholder();
    marker.mount(this, new FragmentSlot(slot?.index ?? 0, -1, slot?.previous));
    addDisposable(() -> {
      marker?.dispose();
      marker = null;
    });

    var prevChildren:Array<Component> = [];
    Observer.track(() -> {
      assert(componentBuildStatus != Building);
      assert(componentLifecycleStatus != Disposed);

      if (componentLifecycleStatus == Disposing) return;

      var newChildren = children.get().filter(c -> c != null);
      
      componentBuildStatus = Building;
      
      switch componentLifecycleStatus {
        case Hydrating(cursor):
          prevChildren = hydrateChildren(this, cursor, newChildren);
        default:
          prevChildren = reconcileChildren(this, prevChildren, newChildren);
      }

      componentBuildStatus = Built;
    });

    addDisposable(() -> prevChildren.resize(0));
  }

  override function updateSlot(?newSlot:Slot) {
    super.updateSlot(newSlot);
    if (marker != null && newSlot != null) {
      marker.updateSlot(new FragmentSlot(newSlot.index, -1, newSlot.previous));
      var previous = marker;
      for (i => child in children.peek()) {
        child.updateSlot(createSlot(i, previous));
        previous = child;
      }
    }
  }

  override function createSlot(localIndex:Int, previous:Null<Component>):Slot {
    var index = slot?.index ?? 0;
    if (previous == null) previous = marker;
    return new FragmentSlot(index, localIndex + 1, previous);
  }

  public function visitChildren(visitor:(child:Component) -> Bool) {
    for (child in children.peek()) {
      if (!visitor(child)) break;
    }
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
