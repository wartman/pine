package pine.html.dom;

import js.Browser;

using pine.html.shared.ObjectTools;

class HtmlElementApplicator extends BaseDomApplicator<HtmlElementComponent<{}>> {
  public function create(component:HtmlElementComponent<{}>):Dynamic {
    var el = component.isSvg 
      ? Browser.document.createElementNS(DomTools.svgNamespace, component.tag) 
      : Browser.document.createElement(component.tag);
    update(el, component);
    return el;
  }

  public function update(object:Dynamic, component:HtmlElementComponent<{}>, ?previousComponent:HtmlElementComponent<{}>) {
    var newAttrs = component.attrs;
    var oldAttrs = previousComponent != null ? previousComponent.attrs : {};
    ObjectTools.diffObject(oldAttrs, newAttrs, DomTools.updateNodeAttribute.bind(object));
  }
}
