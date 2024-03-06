package pine.html.server;

import pine.Constants;
import pine.html.server.Primitive;

class PlaceholderPrimitive extends Primitive {
  public function new() {}

  public function updateContent(content) {}

  public function toString(?options:PrimitiveStringifyOptions):String {
    return '<!--${PlaceholderMarker}-->';
  }
}
