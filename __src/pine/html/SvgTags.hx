package pine.html;

import pine.html.SvgAttributes;

typedef SvgTags = {
  final normal:{
    @:element(js.html.svg.SVGElement) final svg:SvgAttributes;
    @:element(js.html.svg.GElement) final g:BaseAttr;
    @:element(js.html.svg.PathElement) final path:PathAttr;
    @:element(js.html.svg.PolygonElement) final polygon:PolygonAttr;
    @:element(js.html.svg.CircleElement) final circle:CircleAttr;
    @:element(js.html.svg.RectElement) final rect:RectAttr;
    @:element(js.html.svg.EllipseElement) final ellipse:EllipseAttr;
  }
}
