package pine;

import haxe.macro.Expr;

using haxe.macro.Tools;

macro function as(input: Expr, type: Expr) {
  var complexType = type.toString().toComplex();
  return macro cast($input, $complexType);
}
