package pine;

import pine.macro.*;
import kit.macro.*;
import kit.macro.step.*;

function build() {
	return ClassBuilder.fromContext().addBundle(new StructureBuilder()).export();
}

class StructureBuilder implements BuildBundle {
	public function new() {}

	public function steps():Array<BuildStep> return [
		new ConstantFieldBuildStep(),
		new PropertyBuildStep(),
		new ConstructorBuildStep({privateConstructor: false})
	];
}
