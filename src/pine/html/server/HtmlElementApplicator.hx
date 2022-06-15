package pine.html.server;

import pine.render.BaseObjectApplicator;

class HtmlElementApplicator extends BaseObjectApplicator<HtmlElementComponent<{}>> {
  public function create(component:HtmlElementComponent<{}>):Dynamic {
    return new HtmlElementObject(component.tag, component.attrs);
  }

  public function update(object:Dynamic, component:HtmlElementComponent<{}>, ?previousComponent:HtmlElementComponent<{}>) {
    var el:HtmlElementObject = object;
    el.updateAttributes(component.attrs);
  }
}
