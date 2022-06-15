package pine.html.server;

import pine.render.Object;
import pine.html.HtmlRoot;

class ServerRoot extends HtmlRoot<Object> {
  public function createElement():Element {
    return new HtmlRootElement<Object>(this, new ObjectApplicatorCollection([
      HtmlElementComponent.applicatorType => new HtmlElementApplicator(),
      HtmlTextComponent.applicatorType => new HtmlTextApplicator()
    ]));
  }
}