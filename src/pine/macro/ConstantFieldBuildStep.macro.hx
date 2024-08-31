package pine.macro;

import kit.macro.*;
import haxe.macro.Expr;

using kit.macro.Tools;

class ConstantFieldBuildStep implements BuildStep {
	public final priority:Priority = Before;

	public function new() {}

	public function apply(builder:ClassBuilder) {
		var fields = builder.findFieldsByMeta(':constant');

		for (field in fields) {
			parseField(builder, field);
		}
	}

	function parseField(builder:ClassBuilder, field:Field) {
		switch field.kind {
			case FVar(t, e):
				if (!field.access.contains(AFinal)) {
					field.pos.error('@:constant fields must be final');
				}

				var name = field.name;

				builder.hook(Init)
					.addProp({name: name, type: t, optional: e != null})
					.addExpr(if (e == null) {
						macro this.$name = props.$name;
					} else {
						macro if (props.$name != null) this.$name = props.$name;
					});
			default:
				field.pos.error('Invalid field for :constant');
		}
	}
}
