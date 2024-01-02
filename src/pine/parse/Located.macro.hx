package pine.parse;

import haxe.macro.Expr;

typedef Located<T> = {
  public final value:T;
  public final pos:Position;
}
