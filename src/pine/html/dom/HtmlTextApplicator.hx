package pine.html.dom;

class HtmlTextApplicator extends BaseDomApplicator<HtmlTextComponent> {
  public function new() {}

  public function create(component:HtmlTextComponent):Dynamic {
    return new js.html.Text(component.content);
  }

  public function update(object:Dynamic, component:HtmlTextComponent, ?previousComponent:HtmlTextComponent) {
    var text:js.html.Text = object;
    if (previousComponent != null && component.content != previousComponent.content) {
      text.textContent = component.content == null ? '' : component.content;
    }
  }
}
