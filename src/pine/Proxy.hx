package pine;

import pine.core.HasComponentType;
import pine.diffing.Key;
import pine.element.ProxyElementEngine;

/**
  A simple component designed to easily allow Element setup. The `setup`
  callback will only be run once, right before the Proxy component is 
  initialized. See `pine.Effect` for an example of how this can be used.
**/
final class Proxy<T:Component> extends Component implements HasComponentType {
  public final target:ElementOf<T>;
  public final setup:(element:ElementOf<T>)->Void;
  public final child:Null<Child>;

  public function new(props:{
    target:ElementOf<T>,
    setup:(element:ElementOf<T>)->Void,
    ?child:Child,
    ?key:Key
  }) {
    super(props.key);
    target = props.target;
    setup = props.setup;
    child = props.child;
  }

  public function createElement():Element {
    var element:ElementOf<Proxy<T>> = new Element(this, useProxyElementEngine((element:ElementOf<Proxy<T>>) -> element.component.child));
    element.events.beforeInit.add((element, _) -> element.component.setup(element.component.target));
    return element;
  }
}
