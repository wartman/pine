package pine.html.server;

import pine.render.ObjectCursor;
import pine.render.Object;

class ServerBootstrap extends HtmlBootstrap<Object> {
  public function getDefaultRoot():Object {
    return new HtmlElementObject('div', {id: 'root'});
  }

  function createHydrator():HydrationCursor {
    return new ObjectCursor(el);
  }

  function createRoot(child:Component):RootComponent {
    return new ServerRoot({el: el, child: child});
  }
}
