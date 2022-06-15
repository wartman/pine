package pine.html.dom;

import pine.html.HtmlRoot;

class DomRoot extends HtmlRoot<js.html.Element> {
  public function createElement():Element {
    return new HtmlRootElement<js.html.Element>(this, new ObjectApplicatorCollection([
      HtmlElementComponent.applicatorType => new HtmlElementApplicator(),
      HtmlTextComponent.applicatorType => new HtmlTextApplicator()
    ]));
  }
}
