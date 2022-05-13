package pine;

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

  static public macro function warn(expr:haxe.macro.Expr.ExprOf<String>) {
    return macro throw $expr;
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
      pine.Debug.warn($message);
    }
  }
  #end
}
