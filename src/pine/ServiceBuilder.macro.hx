package pine;

import haxe.macro.Context;
import pine.macro.ClassBuilder;
import pine.ProviderBuilder.buildProvider;

function build() {
  var cls = Context.getLocalClass().get();
  var type = Context.getLocalType();
  var builder = new ClassBuilder(Context.getBuildFields());
  var def = switch cls.meta.extract('default') {
    case [ def ]: switch def.params {
      case [ expr ]:
        expr;
      default:
        Context.error('Single expression expected', def.pos);
        return builder.export();
    }
    case []: 
      Context.error('A default value must be provided via @default', cls.pos);
      return builder.export();
    default:
      Context.error('Only one @default is allowed', cls.pos);
      return builder.export();
  }
  var provider = switch buildProvider(type) {
    case TPath(p): p;
    default:
      Context.error('invalid type', cls.pos);
      return builder.export();
  }

  if (cls.superClass != null) {
    Context.error('Services cannot currently extend other classes.', cls.pos);
    return builder.export();
  }

  cls.meta.remove('default');

  builder.add(macro class {
    public static function from(context:pine.Context) {
      return switch $p{provider.pack.concat([ provider.name ])}.maybeFrom(context) {
        case Some(value): value;
        case None: ${def};
      }
    }

    public static function provide(value, render) {
      return new $provider({
        create: () -> value,
        dispose: service -> service.dispose(),
        render: render
      });
    }
  });

  return builder.export();
}
