package pine;

import pine.core.HasComponentType;
import pine.diffing.Key;
import pine.element.*;
import pine.element.core.*;
import pine.element.proxy.*;
import pine.element.state.*;

/**
  The Scope component is designed to help isolate reactive parts 
  of a component, allowing only small sections to update when a Signal
  changes instead of causing an entire Component to re-render.
**/
final class Scope extends Component implements HasComponentType {
  final render:(context:Context)->Component;

  public function new(props:{
    render:(context:Context)->Component,
    ?key:Key
  }) {
    super(props.key);
    this.render = props.render;
  }
  
  function createAdaptorManager(element:Element):AdaptorManager {
    return new CoreAdaptorManager();
  }

  function createAncestorManager(element:Element):AncestorManager {
    return new CoreAncestorManager(element);
  }

  function createChildrenManager(element:Element):ChildrenManager {
    return new TrackedChildrenManager<Scope>(
      element, 
      element -> element.component.render(element)
    );
  }

  function createSlotManager(element:Element):SlotManager {
    return new ProxySlotManager(element);
  }

  function createObjectManager(element:Element):ObjectManager {
    return new ProxyObjectManager(element);
  }
}
