package pine.debug;

class Debug {
  static public macro function assert(expr:haxe.macro.Expr.ExprOf<Bool>, ?message:haxe.macro.Expr.ExprOf<String>) {
    if (haxe.macro.Context.defined('debug')) {
      return createAssertion(expr, message);
    }

    return macro null;
  }

  static public macro function alwaysAssert(expr:haxe.macro.Expr.ExprOf<Bool>, ?message:haxe.macro.Expr.ExprOf<String>) {
    return createAssertion(expr, message);
  }

  static public macro function error(expr:haxe.macro.Expr.ExprOf<String>) {
    var type = haxe.macro.Context.getLocalType();
    var elementType = haxe.macro.Context.getType('pine.Element');
    return if (haxe.macro.Context.unify(elementType, type)) {
      macro @:pos(expr.pos) throw new pine.core.PineElementException(this, $expr);
    } else {
      macro @:pos(expr.pos) throw new pine.core.PineException($expr);
    }
  }

  #if macro
  static function createAssertion(expr:haxe.macro.Expr.ExprOf<Bool>, message:haxe.macro.Expr.ExprOf<String>) {
    switch message {
      case macro null:
        var str = 'Failed assertion: ' + haxe.macro.ExprTools.toString(expr);
        message = macro $v{str};
      default:
    }

    return macro @:pos(expr.pos) if (!$expr) {
      pine.Debug.error($message);
    }
  }
  #end
}
