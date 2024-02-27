package pine.bridge;

import pine.macro.*;
import pine.macro.builder.*;

using Lambda;
using pine.macro.Tools;

final factory = new ClassBuilderFactory([
  new AttributeFieldBuilder(),
  new SignalFieldBuilder(),
  new ObservableFieldBuilder(),
  new ConstructorBuilder({}),
  new ComponentBuilder(),
  new IslandBuilder(),
  new JsonSerializerBuilder({}),
]);

function build() {
  return factory.fromContext().export();
}

class IslandBuilder implements Builder {
  public final priority:BuilderPriority = Late;

  public function new() {}

  public function apply(builder:ClassBuilder) {
    var path = builder.getTypePath().typePathToString();
    builder.add(macro class {
      public static final islandName = $v{path};

      function __islandName() {
        return islandName;
      }

      #if pine.client
      public static function hydrateIslands(adaptor:pine.Adaptor) {
        var elements = pine.bridge.IslandElement.getIslandElementsForComponent(islandName);
        return [ for (el in elements) {
          var props:{} = pine.bridge.IslandElement.getIslandProps(el);
          pine.Root.build(el, adaptor, () -> fromJson(props)).hydrate();
        } ];
      }
      #end
    });
  }
}
