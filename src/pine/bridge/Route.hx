package pine.bridge;

import kit.http.Request;

interface Route {
  public function match(request:Request):Bool;
  public function render(request:Request):Child;
}
