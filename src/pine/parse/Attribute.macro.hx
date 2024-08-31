package pine.parse;

import haxe.macro.Expr;

typedef Attribute = {
	public final name:Located<String>;
	public final value:Expr;
}
