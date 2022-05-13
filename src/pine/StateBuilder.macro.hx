package pine;

import haxe.macro.Context;
import haxe.macro.Expr;
import pine.macro.ClassBuilder;
import pine.macro.ClassMetaDebugger;
import pine.macro.ImmutablePropertyBuilder;
import pine.macro.ReactivePropertyBuilder;

using pine.macro.MacroTools;

class StateBuilder {
  public static function build() {
    var fields = MacroTools.getBuildFieldsSafe();
    var builder = new ClassBuilder(fields);
    var immutableBuilder = new ImmutablePropertyBuilder(fields);
    var reactiveBuilder = new ReactivePropertyBuilder(fields);
    var initProps:ComplexType = TAnonymous(reactiveBuilder.getInitializerProps().concat(immutableBuilder.getProps()));
    var observableType = reactiveBuilder.getObservableObjectType();

    if (Context.defined('debug')) {
      var debugger = new ClassMetaDebugger(fields, ['prop', 'observe'], [
        ':prop' => 'Use `@prop` instead of `@:prop`.',
        ':observe' => 'Use `@observe` instead of `@:observe`.',
        'observable' => '`@observable` is not valid Pine metadata -- did you mean to use `@observe` instead?',
        ':observable' => '`@:observable` is not valid Pine metadata -- did you mean to use `@observe` instead?'
      ]);
      debugger.check();

      if (reactiveBuilder.getObservableObjectProps().length == 0) {
        Context.warning('No observed properties were found while building this class. Consider using a plain class (perhaps using `@:structInit`) or an anonymous object instead of `pine.State`.',
          Context.getLocalClass().get().pos);
      }
    }

    reactiveBuilder.add(macro class {
      final observable:$observableType;

      public function new(props:$initProps) {
        ${reactiveBuilder.getInitializers()};
        ${immutableBuilder.getInitializers()};
        observable = ${reactiveBuilder.instantiateObservableObject()};
      }

      public inline function observe() {
        return observable;
      }

      public inline function select<R>(transform, ?options):Observable<R> {
        return observable.map(transform, options);
      }

      public function dispose() {
        observable.dispose();
      }
    });

    return builder.merge(immutableBuilder).merge(reactiveBuilder).export();
  }
}
