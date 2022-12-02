package pine;

import pine.adapter.Adapter;
import pine.core.HasComponentType;
import pine.diffing.Key;
import pine.element.*;
import pine.element.core.*;
import pine.element.proxy.*;
import pine.hydration.Cursor;

final class Fragment extends Component implements HasComponentType {
  public final children:Array<Component>;

  public function new(props:{
    children:Array<Component>,
    ?key:Key
  }) {
    super(props.key);
    this.children = props.children;
  }

  function createAdapterManager(element:Element):AdapterManager {
    return new CoreAdapterManager();
  }

  function createAncestorManager(element:Element):AncestorManager {
    return new CoreAncestorManager(element);
  }

  function createChildrenManager(element:Element):ChildrenManager {
    return new MultipleChildrenManager(element, context -> {
      var fragment:Fragment = context.getComponent();
      return fragment.children.filter(child -> child != null);
    });
  }

  function createSlotManager(element:Element):SlotManager {
    return new FragmentSlotManager(element);
  }

  function createObjectManager(element:Element):ObjectManager {
    return new FragmentObjectManager(element);
  }

  function createLifecycleHooks():Null<LifecycleHooks<Dynamic>> {
    return null;
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

class FragmentObjectManager extends ProxyObjectManager {
  var marker:Null<Element> = null;
  
  public function new(element:Element) {
    super(element);
    element.hooks.add({
      beforeHydrate: (element:Element, cursor:Cursor) -> {
        var fragment:Fragment = element.getComponent();
        if (fragment.children.length == 0) {
          createMarker();
        }
      },

      shouldHydrate: (element:Element, cursor:Cursor) -> {
        var fragment:Fragment = element.getComponent();
        fragment.children.length > 0;
      }
    });
  }

  override function get():Dynamic {
    var child:Null<Element> = null;
    element.visitChildren(c -> {
      child = c;
      child != null;
    });

    if (child == null) {
      return createMarker().getObject();
    } else if (marker != null) {
      marker.dispose();
      marker = null;
    }

    return child.getObject();
  }

  function createMarker():Element {
    if (marker == null) {
      var component = Adapter.from(element).createPlaceholder();
      marker = component.createElement();
      marker.mount(element, element.slots.get());
    }
    return marker;
  }

  override function dispose() {
    super.dispose();
    if (marker != null) {
      marker.dispose();
      marker = null;
    }
  }
}

class FragmentSlotManager extends CoreSlotManager {
  override function create(localIndex:Int, previous:Null<Element>):Slot {
    var parentSlot = element.slots.get();
    var index = parentSlot == null ? 0 : parentSlot.index;
    return new FragmentSlot(index, localIndex, previous);
  }
}
