package pine.html;

import pine.html.HtmlAttributes;
import pine.signal.Signal;

// Coppied from: https://github.com/haxetink/tink_svgspec
// svg attr reference: https://github.com/dumistoklus/svg-xsd-schema/blob/master/svg.xsd
typedef SvgAttributes = GlobalAttr & {
  @:optional var width:ReadonlySignal<String>;
  @:optional var height:ReadonlySignal<String>;
  @:optional var viewBox:ReadonlySignal<String>;
  @:optional var xmlns:ReadonlySignal<String>; // Generally unused
}

typedef BaseAttr = SvgAttributes & {
  @:optional var transform:ReadonlySignal<String>;
}

typedef PathAttr = BaseAttr & {
  var d:ReadonlySignal<String>;
  @:optional var pathLength:ReadonlySignal<String>;
}

typedef PolygonAttr = BaseAttr & {
  var points:ReadonlySignal<String>;
}

typedef RectAttr = BaseAttr & {
  @:optional var x:ReadonlySignal<String>;
  @:optional var y:ReadonlySignal<String>;
  var width:ReadonlySignal<String>;
  var height:ReadonlySignal<String>;
  @:optional var rx:ReadonlySignal<String>;
  @:optional var ry:ReadonlySignal<String>;
}

typedef CircleAttr = BaseAttr & {
  @:optional var cx:ReadonlySignal<String>;
  @:optional var cy:ReadonlySignal<String>;
  @:optional var r:ReadonlySignal<String>;
}

typedef EllipseAttr = BaseAttr & {
  @:optional var cx:ReadonlySignal<String>;
  @:optional var cy:ReadonlySignal<String>;
  var rx:ReadonlySignal<String>;
  var ry:ReadonlySignal<String>;
}

typedef PresentationAttributes = Color & Containers & FeFlood & FillStroke & FilterPrimitives & FontSpecification & Gradients & Graphics & Images & LightingEffects & Markers & TextContentElements & TextElements & Viewports;

private typedef Color = {
  @:optional var color:ReadonlySignal<String>;
  @:optional var colorInterpolation:ReadonlySignal<String>;
}

private typedef Containers = {}
private typedef FeFlood = {}

private typedef FillStroke = {
  @:optional var fill:ReadonlySignal<String>;
  @:optional var fillOpacity:ReadonlySignal<String>;
  @:optional var fillRule:ReadonlySignal<String>;
  @:optional var stroke:ReadonlySignal<String>;
  @:optional var strokeDasharray:ReadonlySignal<String>;
  @:optional var strokeDashoffset:ReadonlySignal<String>;
  @:optional var strokeLinecap:ReadonlySignal<String>;
  @:optional var strokeLinejoin:ReadonlySignal<String>;
  @:optional var strokeMiterlimit:ReadonlySignal<String>;
  @:optional var strokeOpacity:ReadonlySignal<String>;
  @:optional var strokeWidth:ReadonlySignal<String>;
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
