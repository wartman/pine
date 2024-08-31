package pine.macro;

import kit.macro.*;
import haxe.macro.Expr;

using Lambda;
using kit.macro.Tools;

class SignalFieldBuildStep implements BuildStep {
	public final priority:Priority = Before;

	public function new() {}

	public function apply(builder:ClassBuilder) {
		for (field in builder.findFieldsByMeta(':signal')) {
			parseField(builder, field.getMetadata(':signal'), field);
		}
	}

	function parseField(builder:ClassBuilder, meta:MetadataEntry, field:Field) {
		var name = field.name;

		if (!field.access.contains(AFinal)) {
			field.pos.error(':signal fields must be final');
		}

		switch field.kind {
			case FVar(t, e) if (t == null):
				field.pos.error('Expected a type');
			case FVar(t, e):
				var type = switch t {
					case macro :Null<$t>: macro :pine.signal.Signal<Null<$t>>;
					default: macro :pine.signal.Signal<$t>;
				}
				var isOptional = e != null;

				field.kind = FVar(type, switch e {
					case macro null: macro new pine.signal.Signal(null);
					default: e;
				});

				builder.hook(Init)
					.addProp({
						name: name,
						type: t,
						optional: isOptional
					})
					.addExpr(if (isOptional) {
						macro if (props.$name != null) this.$name = props.$name;
					} else {
						macro this.$name = props.$name;
					});
			default:
				meta.pos.error(':signal cannot be used here');
		}
	}
}
