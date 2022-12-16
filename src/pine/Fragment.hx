package pine;

import pine.core.HasComponentType;
import pine.diffing.Key;
import pine.element.*;
import pine.element.core.*;
import pine.element.object.*;

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
    return new FragmentChildrenManager<Fragment>(
      element,
      element -> element.component.children
    );
  }

  function createSlotManager(element:Element):SlotManager {
    return new FragmentSlotManager(element);
  }

  function createObjectManager(element:Element):ObjectManager {
    return new FragmentObjectManager(element);
  }
}
