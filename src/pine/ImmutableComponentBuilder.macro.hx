package pine;

import haxe.macro.Expr;
import haxe.macro.Context;
import pine.macro.ClassMetaDebugger;
import pine.macro.ImmutablePropertyBuilder;

using Lambda;
using pine.macro.MacroTools;

function build() {
  var fields = MacroTools.getBuildFieldsSafe();
  var builder = new ImmutablePropertyBuilder(fields);

  builder.addProp(MacroTools.makeField('key', macro:pine.Key, true));

  var propsType = builder.getPropsType();
  var props = builder.getProps();
  var comparator:Array<Expr> = [];

  for (prop in props) {
    var name = prop.name;
    comparator.push(macro if (this.$name != Reflect.field(previousComponent, $v{name})) return true);
  }

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
    public static final componentType = new pine.UniqueId();

    public function new(props:$propsType) {
      super(props.key);
      ${builder.getInitializers()}
    }

    @:noCompletion
    function didPropertiesChange(previousComponent:pine.Component):Bool {
      @:mergeBlock $b{comparator};
      return false;
    }

    function getComponentType() {
      return componentType;
    }
  });

  return builder.export();
}
