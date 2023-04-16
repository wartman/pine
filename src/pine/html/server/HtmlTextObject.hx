package pine.html.server;

import pine.object.Object;

using StringTools;

class HtmlTextObject extends Object {
  var content:String;

  public function new(content) {
    this.content = content;
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
    return '<!--#-->' + content.htmlEscape();
  }
}
