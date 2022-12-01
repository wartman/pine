package pine.html;

import pine.html.SvgAttributes;

typedef SvgTags = {
  var normal:{
    @:element(js.html.svg.SVGElement) var svg:SvgAttributes;
    @:element(js.html.svg.GElement) var g:BaseAttr;
    @:element(js.html.svg.PathElement) var path:PathAttr;
    @:element(js.html.svg.PolygonElement) var polygon:PolygonAttr;
    @:element(js.html.svg.CircleElement) var circle:CircleAttr;
    @:element(js.html.svg.RectElement) var rect:RectAttr;
    @:element(js.html.svg.EllipseElement) var ellipse:EllipseAttr;
  }
}
