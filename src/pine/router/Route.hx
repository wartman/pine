package pine.router;

import kit.http.Request;

using Kit;

interface Route {
  public function match(request:Request):Maybe<()->Child>;
}

class SimpleRoute implements Route {
  final matcher:(request:Request)->Maybe<()->Child>;

  public function new(matcher) {
    this.matcher = matcher;
  }

  public function match(request:Request) {
    return matcher(request);
  }
}
