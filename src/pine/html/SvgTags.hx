package pine.html;

import pine.html.SvgAttributes;
import pine.html.HtmlTags;

typedef SvgTags = {
  @:element(js.html.svg.SVGElement) @:svg final svg:SvgAttributes & HasChildren;
  @:element(js.html.svg.GElement) @:svg final g:BaseAttr & HasChildren;
  @:element(js.html.svg.PathElement) @:svg final path:PathAttr & HasChildren;
  @:element(js.html.svg.PolygonElement) @:svg final polygon:PolygonAttr & HasChildren;
  @:element(js.html.svg.CircleElement) @:svg final circle:CircleAttr & HasChildren;
  @:element(js.html.svg.RectElement) @:svg final rect:RectAttr & HasChildren;
  @:element(js.html.svg.EllipseElement) @:svg final ellipse:EllipseAttr & HasChildren;
}
