package pine.macro;

import pine.macro.ProviderBuilder;
import haxe.macro.Context;

using haxe.macro.Tools;

function build() {
  var builder = ClassBuilder.fromContext();
  var type = Context.getLocalType();
  var provider = buildProvider(type);
  var providerTp = switch provider {
    case TPath(p): p;
    default: throw 'assert';
  }
  var providerExpr = macro $p{ providerTp.pack.concat([ providerTp.name ]) };

  builder.add(macro class {
    public static inline function from(context:pine.Component) {
      return $providerExpr.from(context);
    }

    public static inline function maybeFrom(context:pine.Component) {
      return $providerExpr.maybeFrom(context);
    }

    public static inline function provide(props) {
      return new $providerTp(props);
    }
  });

  return builder.export();
}
