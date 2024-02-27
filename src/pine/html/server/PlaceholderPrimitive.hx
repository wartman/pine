package pine.html.server;

import pine.Constants;

class PlaceholderPrimitive extends Primitive {
  public function new() {}

  public function updateContent(content) {}

  public function toString():String {
    return '<!--${PlaceholderMarker}-->';
  }
}
