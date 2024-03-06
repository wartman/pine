package pine.router;

import kit.http.Request;

class Navigator extends Model {
  @:signal public final request:Request;

  public function go(req) {
    request.set(req);
  }
}
