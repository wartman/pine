package pine;

import haxe.macro.Context;
import haxe.macro.Expr;
import pine.macro.ClassBuilder;
import pine.macro.ClassMetaDebugger;
import pine.macro.ImmutablePropertyBuilder;
import pine.macro.TrackedPropertyBuilder;

using pine.macro.MacroTools;

class RecordBuilder {
  public static function build() {
    var fields = MacroTools.getBuildFieldsSafe();
    var builder = new ClassBuilder(fields);
    var immutableBuilder = new ImmutablePropertyBuilder(fields);
    var trackedBuilder = new TrackedPropertyBuilder(fields);
    var initProps:ComplexType = TAnonymous(trackedBuilder.getInitializerProps().concat(immutableBuilder.getProps()));
    var trackedType = trackedBuilder.getTrackedObjectType();

    if (Context.defined('debug')) {
      var debugger = new ClassMetaDebugger(fields, ['prop', 'track'], [
        ':prop' => 'Use `@prop` instead of `@:prop`.',
        ':track' => 'Use `@track` instead of `@:track`.',
      ]);
      debugger.check();

      if (trackedBuilder.getTrackedObjectProps().length == 0) {
        Context.warning('No observed properties were found while building this class. Consider using a plain class (perhaps using `@:structInit`) or an anonymous object instead of `pine.State`.',
          Context.getLocalClass().get().pos);
      }
    }

    // @todo: Implement @transition methods

    trackedBuilder.add(macro class {
      final tracked:$trackedType;

      public function new(props:$initProps) {
        ${trackedBuilder.getInitializers()};
        ${immutableBuilder.getInitializers()};
        tracked = ${trackedBuilder.instantiateTrackedObject()};
      }

      public function dispose() {
        tracked.dispose();
      }
    });

    return builder.merge(immutableBuilder).merge(trackedBuilder).export();
  }
}
