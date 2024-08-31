package pine.html;

import haxe.macro.Expr;
import haxe.macro.Context;
import kit.macro.ClassFieldCollection;

using StringTools;
using kit.macro.Tools;

class Html {
	public static function view(expr:Expr) {
		static var generator:Null<pine.parse.Generator> = null;

		if (generator == null) {
			generator = new pine.parse.Generator(new pine.parse.TagContext([
				'pine.html.HtmlTags',
				'pine.html.SvgTags'
			]));
		}

		var parser = new pine.parse.Parser(expr, {
			generateExpr: generator.generate
		});

		return parser.toExpr();
	}
}
