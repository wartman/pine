package pine.html;

import pine.html.HtmlAttributes;

typedef SvgAttributes = GlobalAttr & {
	final ?width:String;
	final ?height:String;
	final ?viewBox:String;
	final ?xmlns:String; // Generally unused
}

typedef BaseAttr = SvgAttributes & {
	final ?transform:String;
}

typedef PathAttr = BaseAttr & {
	final d:String;
	final ?pathLength:String;
}

typedef PolygonAttr = BaseAttr & {
	final points:String;
}

typedef RectAttr = BaseAttr & {
	final ?x:String;
	final ?y:String;
	final width:String;
	final height:String;
	final ?rx:String;
	final ?ry:String;
}

typedef CircleAttr = BaseAttr & {
	final ?cx:String;
	final ?cy:String;
	final ?r:String;
}

typedef EllipseAttr = BaseAttr & {
	final ?cx:String;
	final ?cy:String;
	final rx:String;
	final ry:String;
}

typedef PresentationAttributes = Color & Containers & FeFlood & FillStroke & FilterPrimitives & FontSpecification & Gradients & Graphics & Images & LightingEffects & Markers & TextContentElements & TextElements & Viewports;

private typedef Color = {
	final ?color:String;
	final ?colorInterpolation:String;
}

private typedef Containers = {}
private typedef FeFlood = {}

private typedef FillStroke = {
	final ?fill:String;
	final ?fillOpacity:String;
	final ?fillRule:String;
	final ?stroke:String;
	final ?strokeDasharray:String;
	final ?strokeDashoffset:String;
	final ?strokeLinecap:String;
	final ?strokeLinejoin:String;
	final ?strokeMiterlimit:String;
	final ?strokeOpacity:String;
	final ?strokeWidth:String;
}

private typedef FilterPrimitives = {}
private typedef FontSpecification = {}
private typedef Gradients = {}
private typedef Graphics = {}
private typedef Images = {}
private typedef LightingEffects = {}
private typedef Markers = {}
private typedef TextContentElements = {}
private typedef TextElements = {}
private typedef Viewports = {}
