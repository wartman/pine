package pine.html.client;

class HtmlTextApplicator extends BaseClientApplicator<HtmlTextComponent> {
  public function create(component:HtmlTextComponent):Dynamic {
    return new js.html.Text(component.content);
  }

  public function update(object:Dynamic, component:HtmlTextComponent, previousComponent:Null<HtmlTextComponent>) {
    var text:js.html.Text = object;
    if (previousComponent == null || component.content != previousComponent.content) {
      text.textContent = component.content == null ? '' : component.content;
    }
  }
}
