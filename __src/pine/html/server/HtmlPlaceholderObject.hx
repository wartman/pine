package pine.html.server;

import pine.object.Object;

class HtmlPlaceholderObject extends Object {
  public function new() {}

  public function toString():String {
    // Important: Placeholders are not used during hydration, so
    // we don't want to output anything here.
    return '';
  }
}
