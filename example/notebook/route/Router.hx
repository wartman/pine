package notebook.route;

import pine.*;

typedef Provider = pine.Provider<Router>;

class Router extends State<Route> {
  public static function from(context:Context) {
    return Provider.from(context);
  }
}
