package pine.debug;

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.Tools;
using haxe.macro.ExprTools;

function warn(e) {
  if (Compiler.getConfiguration().debug) {
    // @todo: Come up with a better way to trace things
    return macro trace($e);
  }
  return macro null;
}

function error(message:ExprOf<String>) {
  var type = Context.getLocalType();
  if (Context.unify(type, (macro:pine.Component).toType())) {
    return macro throw new pine.PineException.PineComponentException($message, this);
  }
  return macro throw new pine.PineException($message);
}

function assert(condition:Expr, ?message:Expr):Expr {
  if (!Compiler.getConfiguration().debug) {
    return macro null;
  }

  switch message {
    case macro null:
      var str = 'Failed assertion: ' + condition.toString();
      message = macro @:pos(condition.pos) $v{str};
    default:
  }

  var err = error(message);
  return macro @:pos(condition.pos) if (!$condition) {
    $err;
  }
}
