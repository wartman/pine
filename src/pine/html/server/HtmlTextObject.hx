package pine.html.server;

import pine.render.Object;

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
    return content.htmlEscape();
  }
}
