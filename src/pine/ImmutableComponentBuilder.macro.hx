package pine;

import haxe.macro.Context;
import pine.macro.ClassMetaDebugger;
import pine.macro.ImmutablePropertyBuilder;

using Lambda;
using pine.macro.MacroTools;

class ImmutableComponentBuilder {
  public static function build() {
    var fields = MacroTools.getBuildFieldsSafe();
    var builder = new ImmutablePropertyBuilder(fields);

    builder.addProp(MacroTools.makeField('key', macro:pine.Key, true));

    var propsType = builder.getPropsType();

    if (Context.defined('debug')) {
      var debugger = new ClassMetaDebugger(fields, ['prop'], [
        'track' => '`@track` can only be used on `pine.ObserverComponent`s. '
                    + 'Did you mean to extend `pine.ObserverComponent` instead '
                    + 'of `pine.ImmutableComponent`?',
        ':prop' => 'Use `@prop` instead of `@:prop`.'
      ]);
      debugger.check();
    }

    builder.add(macro class {
      static final type = new pine.UniqueId();

      public function new(props:$propsType) {
        super(props.key);
        ${builder.getInitializers()}
      }

      function getComponentType() {
        return type;
      }
    });

    return builder.export();
  }
}
