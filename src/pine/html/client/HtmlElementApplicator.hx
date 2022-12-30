package pine.html.client;

import js.Browser;

using pine.core.ObjectTools;
using pine.html.client.DomTools;

class HtmlElementApplicator extends BaseClientApplicator<HtmlElementComponent<{}>> {
  public function create(component:HtmlElementComponent<{}>):Dynamic {
    var el = component.isSvg 
      ? Browser.document.createElementNS(DomTools.svgNamespace, component.tag) 
      : Browser.document.createElement(component.tag);
    update(el, component, null);
    return el;
  }

  public function update(object:Dynamic, component:HtmlElementComponent<{}>, previousComponent:Null<HtmlElementComponent<{}>>) {
    var el:js.html.Element = object;
    var newAttrs = component.getObjectData();
    var oldAttrs = previousComponent != null ? previousComponent.getObjectData() : {};
    oldAttrs.diff(newAttrs, (key, oldValue, newValue) -> {
      el.updateNodeAttribute(key, oldValue, newValue);
    });
  }
}
