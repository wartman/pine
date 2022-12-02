package pine.html.server;

import pine.adapter.Adapter;
import pine.core.HasComponentType;
import pine.object.ObjectCursor;
import pine.object.Object;

class ServerRoot
  extends HtmlRootComponent<Object>
  implements HasComponentType
{
  public static function mount(root:Object, child:Component):ElementOf<ServerRoot> {
    var component = new ServerRoot({ el: root, child: child });
    var element = component.createElement();
    element.mount(null, null);
    return element;
  }

  public static function hydrate(root:Object, child:Component) {
    var component = new ServerRoot({ el: root, child: child });
    var element = component.createElement();
    var cursor = new ObjectCursor(root);
    element.hydrate(cursor, null, null);
    return element;
  }

  public function createAdapter():Adapter {
    return new ServerAdapter();
  }
}
