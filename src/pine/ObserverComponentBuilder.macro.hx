package pine;

import haxe.macro.Context;
import haxe.macro.Expr;
import pine.macro.ClassBuilder;
import pine.macro.ClassMetaDebugger;
import pine.macro.ImmutablePropertyBuilder;
import pine.macro.TrackedPropertyBuilder;

using Lambda;
using haxe.macro.Tools;
using pine.macro.MacroTools;

class ObserverComponentBuilder {
  public static function build() {
    var fields = MacroTools.getBuildFieldsSafe();
    var builder = new ClassBuilder(fields);
    var trackedBuilder = new TrackedPropertyBuilder(fields);
    var immutableBuilder = new ImmutablePropertyBuilder(fields);

    immutableBuilder.addProp(MacroTools.makeField('key', macro:pine.Key, true));

    if (Context.defined('debug')) {
      var debugger = new ClassMetaDebugger(fields, ['prop', 'track'], [
        ':prop' => 'Use `@prop` instead of `@:prop`.',
        ':track' => 'Use `@track` instead of `@:track`.'
      ]);
      debugger.check();
    }

    var initProps:ComplexType = TAnonymous(trackedBuilder.getInitializerProps().concat(immutableBuilder.getProps()));
    var trackedType = trackedBuilder.getTrackedObjectType();

    builder.add(macro class {
      static final type = new pine.UniqueId();

      final tracked:$trackedType;

      public function getComponentType() {
        return type;
      }

      public function new(props:$initProps) {
        super(props.key);
        ${trackedBuilder.getInitializers()};
        ${immutableBuilder.getInitializers()};
        tracked = ${trackedBuilder.instantiateTrackedObject()};
      }
    });

    return builder.merge(immutableBuilder).merge(trackedBuilder).export();
  }
}
