package pine.html.client;

import js.Browser;
import js.html.TemplateElement;
import pine.template.Template;

class ClientTemplate implements Template {
  var template:TemplateElement;

  public function new(html:String) {
    template = cast Browser.document.createElement('template');
    template.innerHTML = html;
  }

  public function clone() {
    return template.cloneNode(true);
  }
}
