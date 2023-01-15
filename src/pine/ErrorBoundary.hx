package pine;

import pine.core.HasComponentType;
import pine.diffing.Key;
import pine.element.BoundaryElementEngine;

using pine.core.OptionTools;

class ErrorBoundary extends Component implements HasComponentType {
  final render:(context:Context)->Component;
  final fallback:Null<(e:ThrownObject)->Component> = null;
  final recover:Null<(e:ThrownObject, next:()->Void)->Void> = null;
  final shouldHandle:Null<(object:Dynamic)->Bool> = null;

  public function new(props:{
    render:(context:Context)->Component,
    ?fallback:(thrown:ThrownObject)->Component,
    ?recover:(thrown:ThrownObject, next:()->Void)->Void,
    ?shouldHandle:(object:Dynamic)->Bool,
    ?key:Key
  }) {
    super(props.key);
    this.render = props.render;
    this.fallback = props.fallback;
    this.recover = props.recover;
    this.shouldHandle = props.shouldHandle;
  }

  public function createElement():Element {
    return new Element(
      this,
      useBoundaryElementEngine(
        (element:ElementOf<ErrorBoundary>) -> element.component.render(element),
        {
          fallback: (element, thrown) -> {
            var fallback = element.component.fallback;
            return fallback == null
              ? new Fragment({ children: [] })
              : fallback(thrown);
          },
          recover: (element, thrown, next) -> {
            var recover = element.component.recover;
            if (recover != null) {
              recover(thrown, next);
            }
          },
          shouldHandle: (element, object) -> {
            var shouldHandle = element.component.shouldHandle;
            if (shouldHandle != null) {
              return shouldHandle(object);
            }
            return object is haxe.Exception;
          }
        }
      ),
      []
    );
  }
}