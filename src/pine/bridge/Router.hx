package pine.bridge;

import kit.http.Request;
import pine.signal.Observer;

class Router extends Component {
  @:attribute final routes:Array<Route>;
  @:attribute final fallback:(request:Request)->Child;

  function render():Child {
    var nav = get(Navigator);
    return Scope.wrap(() -> {
      var request = nav.request();
      for (route in routes) if (route.match(request)) {
        return Observer.untrack(() -> route.render());
      }
      return fallback(request);
    });
  }
}
