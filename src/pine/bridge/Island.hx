package pine.bridge;

import pine.signal.Runtime;

@:autoBuild(pine.bridge.IslandBuilder.build())
abstract class Island extends ProxyView {
  abstract function __islandName():String;
  abstract function toJson():Dynamic;

  #if !pine.client
  override function __initialize() {
    var isIslandChild = getContext(Island) != null;
    __child = if (isIslandChild) {
      __owner.own(() -> Runtime.current().untrack(render));
    } else {
      __owner.own(() -> Runtime.current().untrack(() -> 
        Provider.provide(this).children(IslandElement.build({
          component: __islandName(),
          props: toJson(),
          child: render()
        })))
      );
    }
    __child.mount(this, getAdaptor(), slot);
  }
  #end
}
