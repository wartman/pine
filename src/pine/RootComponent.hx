package pine;

import pine.adaptor.Adaptor;
import pine.debug.Debug;
import pine.diffing.Key;
import pine.element.ProxyElementEngine;

abstract class RootComponent extends ObjectComponent {
  public final child:Component;

  public function new(props:{
    child:Component,
    ?key:Key
  }) {
    this.child = props.child;
    super(props.key);
  }

  abstract public function getRootObject():Dynamic;

  abstract public function createAdaptor():Adaptor;

  public function render() {
    return [ child ];
  }

  override function createElement() {
    // This is a bit ugly but it works.
    //
    // @todo: How do we make this even simpler? Can we rework the
    // engine stuff to make it even more composable?
    return new Element(
      this,
      useProxyElementEngine(
        (element:ElementOf<RootComponent>) -> element.component.render()[0],
        (element:ElementOf<RootComponent>) -> element.component.getRootObject()
      ),
      ([
        (element:ElementOf<RootComponent>) -> {
          element.watchLifecycle({
            beforeInit: (element, _) -> {
              element.adaptor = element.component.createAdaptor();
            },
            beforeHydrate: (element, cursor) -> {
              // Note: all that's happening here is that we need
              // to hydrate the RootComponent's children.
              //
              // This is a bit ugly.
              var children = cursor.currentChildren();
              var obj = children.current();
              Debug.assert(obj != null);
              cursor.move(obj);
            }
          });
        }
      ]:HookCollection<RootComponent>)
    );
  }
}
