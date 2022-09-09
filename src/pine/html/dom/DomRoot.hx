package pine.html.dom;

import pine.html.HtmlRoot;

class DomRoot extends HtmlRoot<js.html.Element> {
  public function createElement():Element {
    return new RootElement(this, new DomAdapter());
  }
}
