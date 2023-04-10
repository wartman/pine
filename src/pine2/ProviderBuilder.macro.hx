package pine2;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import pine.macro.ClassBuilder;

using haxe.macro.Tools;
using pine2.internal.macro.MacroTools;

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
  var pack = [ 'pine2' ];
  var name = 'Provider';
  var typeName = type.toString();
  var ct = type.toComplexType();
  var providerName = name + '_' + type.stringifyTypeForClassName();
  var providerPath:TypePath = { pack: pack, name: providerName, params: [] };
  var providerCt:ComplexType = TPath(providerPath);

  if (providerPath.typePathExists()) return providerCt;

  var builder = new ClassBuilder([]);
  
  builder.add(macro class {
    public static function from(component:pine2.Component):$ct {
      return switch maybeFrom(component) {
        case Some(value): 
          value;
        case None: 
          throw new pine2.PineException('No provider exists for the type ' + $v{typeName});
      }
    }

    public static function maybeFrom(component:pine2.Component):kit.Maybe<$ct> {
      return component
        .findAncestor(parent -> parent is $providerCt)
        .map((component:$providerCt) -> component.getValue());
    }
  });


  Context.defineType({
    pack: pack,
    name: providerName,
    pos: (macro null).pos,
    kind: TDClass({
      pack: [ 'pine2' ],
      name: 'Provider',
      sub: 'ProviderComponent',
      params: [TPType(ct)]
    }, null, false, true, false),
    meta: [],
    fields: builder.export()
  });

  return providerCt;
}
