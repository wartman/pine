package pine.debug;

// @todo: Consider freeing these functions from their
// static class.
class Debug {
  static public macro function assert(expr:haxe.macro.Expr.ExprOf<Bool>, ?message:haxe.macro.Expr.ExprOf<String>) {
    if (haxe.macro.Context.defined('debug')) {
      return createAssertion(expr, message);
    }

    return macro null;
  }

  static public macro function warn(message:haxe.macro.Expr.ExprOf<String>) {
    if (haxe.macro.Context.defined('debug')) {
      if (haxe.macro.Context.defined('nodejs')) {
        return macro js.Node.console.warn($message);
      }
      if (haxe.macro.Context.defined('sys')) {
        return macro Sys.println('Warning: ' + $message);
      }
      if (haxe.macro.Context.defined('js')) {
        return macro js.Browser.console.warn($message);
      }
    }
    return macro null;
  }

  static public macro function alwaysAssert(expr:haxe.macro.Expr.ExprOf<Bool>, ?message:haxe.macro.Expr.ExprOf<String>) {
    return createAssertion(expr, message);
  }

  static public macro function error(expr:haxe.macro.Expr.ExprOf<String>) {
    var type = haxe.macro.Context.getLocalType();
    var elementType = haxe.macro.Context.getType('pine.Element');
    return macro @:pos(expr.pos) throw new pine.core.PineException($expr);
  }

  #if macro
  static function createAssertion(expr:haxe.macro.Expr.ExprOf<Bool>, message:haxe.macro.Expr.ExprOf<String>) {
    switch message {
      case macro null:
        var str = 'Failed assertion: ' + haxe.macro.ExprTools.toString(expr);
        message = macro @:pos(expr.pos) $v{str};
      default:
    }

    return macro @:pos(expr.pos) if (!$expr) {
      pine.debug.Debug.error($message);
    }
  }
  #end
}
