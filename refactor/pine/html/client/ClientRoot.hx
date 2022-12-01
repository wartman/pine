package pine.html.client;

import pine.core.HasComponentType;
import pine.adapter.Adapter;

final class ClientRoot 
  extends HtmlRootComponent<js.html.Element>
  implements HasComponentType
{
  public static function mount(root:js.html.Element, child:Component):ElementOf<ClientRoot> {
    var component = new ClientRoot({ el: root, child: child });
    var element = component.createElement();
    element.mount(null, null);
    return element;
  }

  public static function hydrate(root:js.html.Element, child:Component) {
    var component = new ClientRoot({ el: root, child: child });
    var element = component.createElement();
    var cursor = new ClientCursor(root);
    element.hydrate(cursor, null, null);
    return element;
  }

  public function createAdapter():Adapter {
    return new ClientAdapter();
  }
}
