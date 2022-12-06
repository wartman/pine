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
    return new InlineChildrenManager(element, context -> {
      var fragment:Fragment = context.getComponent();
      return fragment.children.filter(child -> child != null);
    });
  }

  function createSlotManager(element:Element):SlotManager {
    return new InlineSlotManager(element);
  }

  function createObjectManager(element:Element):ObjectManager {
    return new InlineObjectManager(element);
  }
}
