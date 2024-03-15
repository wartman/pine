package pine;

import pine.macro.*;
import haxe.macro.Context;
import haxe.macro.Expr;

using pine.macro.Tools;
using haxe.macro.Tools;

final builderFactory = new ClassBuilderFactory([
  new ContextBuilder()
]);

function build() {
  return builderFactory.fromContext().export();
}

class ContextBuilder implements Builder {
  public final priority:BuilderPriority = Late;

  public function new() {}

  public function apply(builder:ClassBuilder) {
    var cls = builder.getClass();
    var tp:TypePath = builder.getTypePath();
    var fallback = switch cls.meta.extract(':fallback') {
      case [ fallback ]: switch fallback.params {
        case [ expr ]:
          expr;
        case []:
          Context.error('Expression required', fallback.pos);
        default:
          Context.error('Too many params', fallback.pos);
      }
      case []:
        Context.error('Context classes require :fallback meta', cls.pos);
      default:
        Context.error('Only one :fallback meta is allowed', cls.pos);
    }
    var createParams:Array<TypeParamDecl> = cls.params.length > 0
      ? [ for (p in cls.params) { name: p.name, constraints: p.extractTypeParams() } ]
      : [];
    var ret:ComplexType = TPath({
      pack: tp.pack,
      name: tp.name,
      // @todo: ...no idea if this will work. Probably not.
      params: createParams.map(p -> TPType(TPath({ name: p.name, pack: [] })))
    });
    var constructors = macro class {
      @:noUsing
      public inline static function from(context:pine.View):$ret {
        return @:pos(fallback.pos) return maybeFrom(context).or(() -> $fallback);
      }

      @:noUsing
      public static function maybeFrom(context:pine.View):kit.Maybe<$ret> {
        return Kit.toMaybe(context.getContext($p{tp.pack.concat([tp.name])}));
      }
    }

    builder.addField(constructors
      .getField('from')
      .unwrap()
      .applyParameters(createParams));
    builder.addField(constructors
      .getField('maybeFrom')
      .unwrap()
      .applyParameters(createParams));
  }
}

