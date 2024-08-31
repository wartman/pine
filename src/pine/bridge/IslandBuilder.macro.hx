package pine.bridge;

import kit.macro.*;
import kit.macro.step.*;
import pine.ComponentBuilder;

using Lambda;
using haxe.macro.Tools;

function build() {
	return ClassBuilder.fromContext()
		.addBundle(new ComponentBuilder())
		.addStep(new IslandBuilder())
		.addStep(new JsonSerializerBuildStep({
			customParser: options -> switch options.type.toType().toComplexType() {
				case macro :pine.signal.Signal<$wrappedType>:
					var name = options.name;
					Some(options.parser(macro this.$name.get(), name, wrappedType));
				// case macro :pine.Children:
				// 	var name = options.name;
				// 	Some({
				// 		serializer: macro pine.bridge.SerializableChildren.toJson(this, this.$name),
				// 		deserializer: macro pine.bridge.SerializableChildren.fromJson(Reflect.field(data, $v{name}))
				// 	});
				// // @todo: handle `pine.Child` as well
				default:
					None;
			},
			constructorAccessor: macro build,
			returnType: macro :pine.Child
		}))
		.export();
}

class IslandBuilder implements BuildStep {
	public final priority:Priority = Late;

	public function new() {}

	public function apply(builder:ClassBuilder) {
		var path = builder.getType().follow().toComplexType().toString();

		builder.add(macro class {
			public static final islandName = $v{path};

			function __islandName() {
				return islandName;
			}

			#if pine.client
			public static function hydrateIslands(adaptor:pine.Adaptor) {
				var elements = pine.bridge.IslandElement.getIslandElementsForComponent(islandName);
				return [for (el in elements) {
					var props:{} = pine.bridge.IslandElement.getIslandProps(el);
					pine.Root.build(el, adaptor, () -> fromJson(props)).hydrate();
				}];
			}
			#end
		});
	}
}
