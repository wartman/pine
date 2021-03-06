package pine.html.server;

import pine.render.BaseObjectApplicator;

class HtmlTextApplicator extends BaseObjectApplicator<HtmlTextComponent> {
  public function create(component:HtmlTextComponent):Dynamic {
    return new HtmlTextObject(component.content);
  }

  public function update(object:Dynamic, component:HtmlTextComponent, ?previousComponent:HtmlTextComponent) {
    var text:HtmlTextObject = object;
    text.updateContent(component.content);
  }
}
