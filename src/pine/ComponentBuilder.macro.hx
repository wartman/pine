package pine;

import haxe.macro.Expr;
import kit.macro.*;
import kit.macro.step.*;
import pine.macro.*;

using kit.macro.Tools;
using Lambda;

function build() {
	return ClassBuilder.fromContext().addBundle(new ComponentBuilder()).export();
}

class ComponentBuilder implements BuildBundle implements BuildStep {
	public final priority:Priority = Late;

	public function new() {}

	public function steps():Array<BuildStep> return [
		new AttributeFieldBuildStep(),
		new ObservableFieldBuildStep(),
		new SignalFieldBuildStep(),
		new ComputedFieldBuildStep(),
		new ConstructorBuildStep({}),
		this
	];

	public function apply(builder:ClassBuilder) {
		var props = builder.hook(Init).getProps().concat(builder.hook(LateInit).getProps());
		var cls = builder.getClass();
		var tp = builder.getTypePath();
		var params = cls.params.toTypeParamDecl();
		var propType:ComplexType = TAnonymous(props);
		var constructors = macro class {
			@:fromMarkup
			@:noUsing
			public inline static function build(props:$propType) {
				return new $tp(props);
			}
		}

		switch builder.findFieldsByMeta(':children') {
			case [field]:
				var meta = field.getMetadata(':children');
				var prop = props.find(p -> p.name == field.name);
				if (prop == null) {
					meta.pos.error('Invalid target for :children');
				}
				prop.meta.push({name: ':children', params: [], pos: meta.pos});
			case []:
			case tooMany:
				tooMany[1].getMetadata(':children').pos.error('Only one :children field is allowed');
		}

		switch builder.findField('build') {
			case None:
			case Some(field):
				field.pos.error('The name "build" is reserved for components');
		}

		builder.addField(constructors
			.getField('build')
			.orThrow()
			.applyParameters(params));

		// for (prop in props) {
		//   var name = prop.name;
		//   var field = builder.findField(name).orThrow();
		//   switch field.kind {
		//     case FVar(_, _) if (!field.access.contains(AFinal) && !field.access.contains(AStatic)):
		//       var withName = 'with' + name.charAt(0).toUpperCase() + name.substr(1);
		//       builder.add(macro class {
		//         public function $withName(value) {
		//           this.$name = value;
		//           return this;
		//         }
		//       });
		//     default:
		//   }
		// }
	}
}
