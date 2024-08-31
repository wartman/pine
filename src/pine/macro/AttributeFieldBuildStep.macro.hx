package pine.macro;

import kit.macro.*;
import haxe.macro.Expr;

using kit.macro.Tools;

class AttributeFieldBuildStep implements BuildStep {
	public final priority:Priority = Before;

	public function new() {}

	public function apply(builder:ClassBuilder) {
		var fields = builder.findFieldsByMeta(':attribute');
		for (field in fields) {
			parseField(builder, field);
		}
	}

	function parseField(builder:ClassBuilder, field:Field) {
		switch field.kind {
			case FVar(t, e):
				var name = field.name;
				builder.hook(Init)
					.addProp({name: name, type: t, optional: e != null})
					.addExpr(if (e == null) {
						macro this.$name = props.$name;
					} else {
						macro if (props.$name != null) this.$name = props.$name;
					});
			default:
				field.pos.error('Invalid field for :attribute');
		}
	}
}
