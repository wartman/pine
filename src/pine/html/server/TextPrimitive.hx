package pine.html.server;

using StringTools;

class TextPrimitive extends Primitive {
  var content:String;
  final raw:Bool;

  public function new(content, raw = true) {
    this.content = content;
    this.raw = raw;
  }

  public function updateContent(content) {
    if (content == null) content = '';
    this.content = content;
  }

  public function toString():String {
    // Important: we prefix all strings with a comment to ensure
    // that text components are split up during hydration. On the
    // client side comments will be ignored, but should still ensure
    // text nodes are properly delimited.
    //
    // You can use the `raw` option to output the text directly. Use this
    // sparingly -- it's intended only for things like outputting
    // JSON, CSS or JS in a script or style tag. 
    return raw ? '<!--#-->' + content.htmlEscape() : content;
  }
}
