package pine.core;

import haxe.macro.Context;
import pine.macro.ClassBuilder;
import pine.macro.MacroTools;

using Lambda;

function build() {
  return process(getBuildFieldsSafe()).export();
}

function process(fields) {
  var builder = new ClassBuilder(fields);

  for (field in builder.findFieldsByMeta(':lazy')) switch field.kind {
    case FVar(t, null):
      Context.error('An expression is required', field.pos);
    case FVar(t, e) if (e != null):
      var meta = field.meta.find(m -> m.name == ':lazy');
      switch meta.params {
        case []:
          var name = field.name;
          var backingName = 'backing_$name';
          var getterName = 'get_$name';

          field.kind = FProp('get', 'never', t, null);
          builder.add(macro class {
            @:noCompletion var $backingName:Null<$t> = null;
            
            function $getterName():$t {
              if (this.$backingName == null) {
                this.$backingName = $e;
              }
              return this.$backingName;
            }
          });
        default:
          Context.error('Unexpected argument', meta.pos);
      }
    default:
      Context.error('Can only be used on vars', field.pos);
  }

  return builder;
}