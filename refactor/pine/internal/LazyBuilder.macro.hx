package pine.internal;

import haxe.macro.Context;
import pine.macro.ClassBuilder;
import pine.macro.MacroTools;

using Lambda;

class LazyBuilder extends ClassBuilder {
  public static function build() {
    var builder = new LazyBuilder(getBuildFieldsSafe());
    return builder.export();
  }

  public function new(fields) {
    super(fields);
    process();
  }

  function process() {
    for (field in findFieldsByMeta('lazy')) switch field.kind {
      case FVar(t, null):
        Context.error('An expression is required', field.pos);
      case FVar(t, e) if (e != null):
        var meta = field.meta.find(m -> m.name == 'lazy');
        field.meta.remove(meta);

        switch meta.params {
          case []:
            var name = field.name;
            var backingName = 'backing_$name';
            var getterName = 'get_$name';

            field.kind = FProp('get', 'never', t, null);
            add(macro class {
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
  }
}