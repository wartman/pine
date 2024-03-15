package pine.router;

import pine.debug.Debug.error;
import kit.http.*;

@:fallback(error('No Navigator found'))
class Navigator extends Model implements Context {
  // @todo: Potentially allow `body` in here? Likely won't be needed much.
  @:json(
    to = { method: value.method, url: value.url.toString() },
    from = new Request(Method.parse(value.method).or(Method.Get), value.url)
  )
  @:signal public final request:Request;

  #if pine.client
  function new() {
    // @todo: Watch the browser for push/pop state
  }
  #end

  public function go(req) {
    #if pine.client
      // @todo: Push to the browser
    #end
    request.set(req);
  }
}
