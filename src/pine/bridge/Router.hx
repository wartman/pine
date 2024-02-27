package pine.bridge;

import kit.http.Request;
import pine.signal.Observer;
import pine.signal.Signal;

class Router extends Component {
  @:signal final currentRequest:Request;
  @:attribute final routes:Array<Route>;
  @:attribute final fallback:(request:Request)->Child;

  public function go(request:Request) {
    var current = currentRequest.peek();

    if (
      request.url.toString() == current.url.toString() 
      && request.method == current.method
    ) return;
    
    currentRequest.set(request);
  }

  function render():Child {
    return Provider
      .provide(this)
      .children(Scope.wrap(() -> {
        var request = currentRequest();
        for (route in routes) if (route.match(request)) {
          return Observer.untrack(() -> route.render(request));
        }
        return fallback(request);
      }));
  }
}
