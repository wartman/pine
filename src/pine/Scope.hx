package pine;

import pine.core.HasComponentType;
import pine.diffing.Key;
import pine.element.TrackedElementEngine;

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

  public function createElement() {
    return new Element(
      this,
      useTrackedProxyEngine((element:ElementOf<Scope>) -> element.component.render(element))
    );
  }
}
