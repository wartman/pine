package pine;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import pine.macro.ClassBuilder;
import pine.macro.MacroTools;

using haxe.macro.Tools;
using pine.macro.MacroTools;

function buildGeneric() {
  return switch Context.getLocalType() {
    case TInst(_, [TMono(t)]):
      Context.error('Requires a concrete type', Context.currentPos());
    case TInst(_, [type]):
      buildProvider(type);
    case TInst(_, []):
      buildProvider((macro:Dynamic).toType());
    default:
      throw 'assert';
  }
}

function resolveProvider(el:Expr, kind:Expr) {
  var type = kind.resolveComplexType().toType();
  var tp = switch buildProvider(type) {
    case TPath(p): p;
    default:
      Context.error('invalid type', kind.pos);
      null;
  }
  return macro $p{tp.pack.concat([tp.name])}.from($el);
}

function buildProvider(type:Type) {
  var pack = [ 'pine' ];
  var name = 'Provider';
  var typeName = type.toString();
  var ct = type.toComplexType();
  var providerName = name + '_' + type.stringifyTypeForClassName();
  var providerPath:TypePath = { pack: pack, name: providerName, params: [] };

  if (providerPath.typePathExists()) return TPath(providerPath);

  var fields = getBuildFieldsSafe();
  var builder = new ClassBuilder(fields);
  
  builder.add(macro class {
    public static function from(context:pine.Context):$ct {
      return switch maybeFrom(context) {
        case Some(value): value;
        case None: throw new pine.core.PineException(
          'No provider exists for the type ' + $v{typeName}
        );
      }
    }

    public static function maybeFrom(context:pine.Context):haxe.ds.Option<$ct> {
      return switch context.queryAncestors().find(parent -> parent.getComponent().getComponentType() == componentType) {
        case Some(element):
          var value = (element.getComponent():pine.Provider.ProviderComponent<$ct>).getValue();
          if (value == null) return None;
          Some(value);
        case None: None;
      }
    }
  });

  Context.defineType({
    pack: pack,
    name: providerName,
    pos: (macro null).pos,
    kind: TDClass({
      pack: [ 'pine' ],
      name: 'Provider',
      sub: 'ProviderComponent',
      params: [TPType(ct)]
    }, [
      { pack: [ 'pine', 'core' ], name: 'HasComponentType' }
    ], false, true, false),
    meta: [],
    fields: builder.export()
  });

  return TPath(providerPath);
}
