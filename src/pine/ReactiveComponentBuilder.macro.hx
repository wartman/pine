package pine;

import haxe.macro.Context;
import haxe.macro.Expr;
import pine.macro.ClassBuilder;
import pine.macro.ClassMetaDebugger;
import pine.macro.ImmutablePropertyBuilder;
import pine.macro.ReactivePropertyBuilder;

using Lambda;
using haxe.macro.Tools;
using pine.macro.MacroTools;

class ReactiveComponentBuilder {
  public static function build() {
    var fields = MacroTools.getBuildFieldsSafe();
    var builder = new ClassBuilder(fields);
    var reactiveBuilder = new ReactivePropertyBuilder(fields);
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

      if (reactiveBuilder.getObservableObjectProps().length == 0) {
        Context.warning('No observed properties were found while building this class. Consider extending `pine.ImmutableComponent` instead.',
          Context.getLocalClass().get().pos);
      }
    }

    var initProps:ComplexType = TAnonymous(reactiveBuilder.getInitializerProps().concat(immutableBuilder.getProps()));
    var observableType = reactiveBuilder.getObservableObjectType();

    switch builder.findField('render') {
      case None:
      case Some(render):
        switch render.kind {
          case FFun(f):
            var expr = f.expr;
            f.expr = macro return observable.render(_ -> $expr);
          default:
        }
    }

    builder.add(macro class {
      static final type = new pine.UniqueId();

      final observable:$observableType;

      public function getComponentType() {
        return type;
      }

      public function new(props:$initProps) {
        super(props.key);
        ${reactiveBuilder.getInitializers()};
        ${immutableBuilder.getInitializers()};
        observable = ${reactiveBuilder.instantiateObservableObject()};
      }
    });

    return builder.merge(immutableBuilder).merge(reactiveBuilder).export();
  }
}
