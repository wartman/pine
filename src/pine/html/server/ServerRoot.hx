package pine.html.server;

import pine.render.Object;

class ServerRoot extends HtmlRoot<Object> {
  public function createElement():Element {
    return new RootElement(this, new ServerAdapter());
  }
}
