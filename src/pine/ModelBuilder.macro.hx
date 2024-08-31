package pine;

import kit.macro.*;
import kit.macro.step.*;
import pine.macro.*;

using haxe.macro.Tools;

function build() {
	return ClassBuilder.fromContext().addBundle(new ModelBuilder()).export();
}

class ModelBuilder implements BuildBundle {
	public function new() {}

	public function steps():Array<BuildStep> return [
		new ConstantFieldBuildStep(),
		new SignalFieldBuildStep(),
		new ComputedFieldBuildStep(),
		new ObservableFieldBuildStep(),
		new JsonSerializerBuildStep({
			customParser: options -> switch options.type.toType().toComplexType() {
				case macro :pine.signal.Signal<$wrappedType>:
					// Unwrap any signals and then let the base parser take over.
					var name = options.name;
					Some(options.parser(macro this.$name.get(), name, wrappedType));
				default:
					None;
			}
		}),
		new ConstructorBuildStep({})
	];
}
