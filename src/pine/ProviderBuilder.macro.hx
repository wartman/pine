package pine;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import pine.internal.macro.ClassBuilder;

using haxe.macro.Tools;
using pine.internal.macro.MacroTools;

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
  var providerCt:ComplexType = TPath(providerPath);

  if (providerPath.typePathExists()) return providerCt;

  var builder = new ClassBuilder([]);
  
  builder.add(macro class {
    public static function from(component:pine.Component):$ct {
      return switch maybeFrom(component) {
        case Some(value): 
          value;
        case None:
          #if debug
          throw new pine.PineException(component.getFormattedErrorMessage('No provider exists for the type ' + $v{typeName}));
          #else
          throw new pine.PineException('No provider exists for the type ' + $v{typeName});
          #end
      }
    }

    public static function maybeFrom(component:pine.Component):kit.Maybe<$ct> {
      return component
        .findAncestor(parent -> parent is $providerCt)
        .map((component:$providerCt) -> component.getValue());
    }
  });

  if (Context.unify(type, (macro:pine.Disposable).toType())) {
    builder.add(macro class {
      public function new(props:{
        value:$ct,
        build:(value:$ct) -> Component,
        ?dispose:(value:$ct) -> Void,
      }) {
        super({
          value: props.value,
          build: props.build,
          dispose: props.dispose ?? value -> value.dispose() 
        });
      }
    });
  }

  Context.defineType({
    pack: pack,
    name: providerName,
    pos: (macro null).pos,
    kind: TDClass({
      pack: [ 'pine' ],
      name: 'Provider',
      sub: 'ProviderComponent',
      params: [TPType(ct)]
    }, null, false, true, false),
    meta: [],
    fields: builder.export()
  });

  return providerCt;
}
