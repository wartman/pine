package pine.parse;

import pine.parse.Located;
import haxe.macro.Expr;

enum NodeDef {
	NText(text:String);
	NNode(name:Located<String>, attributes:Array<Attribute>, ?children:Array<Node>);
	NFragment(children:Array<Node>);
	NExpr(expr:Expr);
}

typedef Node = Located<NodeDef>;
