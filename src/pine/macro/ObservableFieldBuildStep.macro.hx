package pine.macro;

import kit.macro.*;
import haxe.macro.Expr;

using kit.macro.Tools;

class ObservableFieldBuildStep implements BuildStep {
	public final priority:Priority = Before;

	public function new() {}

	public function apply(builder:ClassBuilder) {
		for (field in builder.findFieldsByMeta(':observable')) {
			parseField(builder, field.getMetadata(':observable'), field);
		}
	}

	function parseField(builder:ClassBuilder, meta:MetadataEntry, field:Field) {
		var name = field.name;

		if (!field.access.contains(AFinal)) {
			field.pos.error(':observable fields must be final');
		}

		switch field.kind {
			case FVar(t, e):
				var type = switch t {
					case macro :Null<$t>: macro :pine.signal.Signal.ReadOnlySignal<Null<$t>>;
					default: macro :pine.signal.Signal.ReadOnlySignal<$t>;
				}

				field.kind = FVar(type, switch e {
					case macro null: macro new pine.signal.Signal(null);
					default: e;
				});

				builder.hook(LateInit)
					.addProp({
						name: name,
						type: type,
						optional: e != null
					})
					.addExpr(if (e == null) {
						macro this.$name = props.$name;
					} else {
						macro if (props.$name != null) this.$name = props.$name;
					});
			default:
				meta.pos.error(':observable cannot be used here');
		}
	}
}
