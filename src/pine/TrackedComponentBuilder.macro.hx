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

class TrackedComponentBuilder {
  public static function build() {
    var fields = MacroTools.getBuildFieldsSafe();
    var builder = new ClassBuilder(fields);
    var trackedBuilder = new TrackedPropertyBuilder(fields);
    var immutableBuilder = new ImmutablePropertyBuilder(fields);

    immutableBuilder.addProp(MacroTools.makeField('key', macro:pine.Key, true));

    if (Context.defined('debug')) {
      var debugger = new ClassMetaDebugger(fields, ['prop', 'observe'], [
        ':prop' => 'Use `@prop` instead of `@:prop`.',
        ':observe' => 'Use `@observe` instead of `@:observe`.',
        'observable' => '`@observable` is not valid Pine metadata -- did you mean to use `@observe` instead?',
        ':observable' => '`@:observable` is not valid Pine metadata -- did you mean to use `@observe` instead?'
      ]);
      debugger.check();

      // if (trackedBuilder.getTrackedObjectProps().length == 0) {
      //   Context.warning('No observed properties were found while building this class. Consider extending `pine.ImmutableComponent` instead.',
      //     Context.getLocalClass().get().pos);
      // }
    }

    var initProps:ComplexType = TAnonymous(trackedBuilder.getInitializerProps().concat(immutableBuilder.getProps()));
    var trackedType = trackedBuilder.getTrackedObjectType();

    switch builder.findField('render') {
      case None:
      case Some(render):
        switch render.kind {
          case FFun(f):
            var expr = f.expr;
            f.expr = macro return new pine.track.ObserverComponent({render: _ -> $expr});
          default:
        }
    }

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
