package pine.html;

import pine.html.SvgAttributes;
import pine.html.HtmlTags;

typedef SvgTags = {
	@:element(js.html.svg.SVGElement) @:svg public final svg:SvgAttributes & HasChildren;
	@:element(js.html.svg.GElement) @:svg public final g:BaseAttr & HasChildren;
	@:element(js.html.svg.PathElement) @:svg public final path:PathAttr & HasChildren;
	@:element(js.html.svg.PolygonElement) @:svg public final polygon:PolygonAttr & HasChildren;
	@:element(js.html.svg.CircleElement) @:svg public final circle:CircleAttr & HasChildren;
	@:element(js.html.svg.RectElement) @:svg public final rect:RectAttr & HasChildren;
	@:element(js.html.svg.EllipseElement) @:svg public final ellipse:EllipseAttr & HasChildren;
}
