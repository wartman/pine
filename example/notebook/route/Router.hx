package notebook.route;

import pine.*;

typedef Provider = pine.Provider<Router>;

class Router extends Signal<Route> {
  public static function from(context:Context) {
    return Provider.from(context);
  }
}
