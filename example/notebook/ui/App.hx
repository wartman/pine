package notebook.ui;

import pine.*;
import notebook.data.*;
import notebook.route.*;

class App extends ImmutableComponent {
  public function render(context:Context):Component {
    return new Store.Provider({
      create: () -> Store.load(),
      dispose: store -> store.dispose(),
      render: store -> new Router.Provider({
        create: () -> new Router(Home),
        dispose: router -> router.dispose(),
        render: router -> new RouteHandler({ router: router })
      })
    });
  }
}
