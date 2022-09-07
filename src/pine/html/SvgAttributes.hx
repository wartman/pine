package pine.html;

import pine.html.HtmlAttributes;

// Coppied from: https://github.com/haxetink/tink_svgspec
// svg attr reference: https://github.com/dumistoklus/svg-xsd-schema/blob/master/svg.xsd
typedef SvgAttributes = GlobalAttr & {
  @:optional var width:String;
  @:optional var height:String;
  @:optional var viewBox:String;
  @:optional var xmlns:String; // Generally unused
}

typedef BaseAttr = SvgAttributes & {
  @:optional var transform:String;
}

typedef PathAttr = BaseAttr & {
  var d:String;
  @:optional var pathLength:String;
}

typedef PolygonAttr = BaseAttr & {
  var points:String;
}

typedef RectAttr = BaseAttr & {
  @:optional var x:String;
  @:optional var y:String;
  var width:String;
  var height:String;
  @:optional var rx:String;
  @:optional var ry:String;
}

typedef CircleAttr = BaseAttr & {
  @:optional var cx:String;
  @:optional var cy:String;
  @:optional var r:String;
}

typedef EllipseAttr = BaseAttr & {
  @:optional var cx:String;
  @:optional var cy:String;
  var rx:String;
  var ry:String;
}

typedef PresentationAttributes = Color & Containers & FeFlood & FillStroke & FilterPrimitives & FontSpecification & Gradients & Graphics & Images & LightingEffects & Markers & TextContentElements & TextElements & Viewports;

private typedef Color = {
  @:optional var color:String;
  @:optional var colorInterpolation:String;
}

private typedef Containers = {}
private typedef FeFlood = {}

private typedef FillStroke = {
  @:optional var fill:String;
  @:optional var fillOpacity:String;
  @:optional var fillRule:String;
  @:optional var stroke:String;
  @:optional var strokeDasharray:String;
  @:optional var strokeDashoffset:String;
  @:optional var strokeLinecap:String;
  @:optional var strokeLinejoin:String;
  @:optional var strokeMiterlimit:String;
  @:optional var strokeOpacity:String;
  @:optional var strokeWidth:String;
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
