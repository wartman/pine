package pine;

import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;
import pine.macro.ClassBuilder;

using haxe.macro.Tools;
using pine.macro.MacroTools;

class ConsumerBuilder {
  public static function buildGeneric() {
    return switch Context.getLocalType() {
      case TInst(_, [TMono(t)]):
        Context.error('Requires a concrete type', Context.currentPos());
      case TInst(_, [TAnonymous(a)]):
        buildMultiConsumer(TAnonymous(a), a.get());
      case TInst(_, [type]):
        buildConsumer(type);
      case TInst(_, []):
        buildConsumer((macro:Dynamic).toType());
      default:
        throw 'assert';
    }
  }

  static function buildMultiConsumer(type:Type, a:AnonType) {
    var pack = ['pine'];
    var name = 'Consumer';
    var ct = type.toComplexType();
    var consumerName = name + '_' + type.stringifyTypeForClassName();
    var consumerPath:TypePath = {pack: pack, name: consumerName, params: []};

    if (!consumerPath.typePathExists()) {
      var builder = createBuilderWithDefaults();
      var fields = a.fields;
      var resolvedFields:Array<ObjectField> = [];

      for (field in fields) {
        var provider = switch ProviderBuilder.buildProvider(field.type) {
          case TPath(p): p;
          default: throw 'assert';
        }
        resolvedFields.push({
          field: field.name,
          expr: macro {
            var item = $p{provider.pack.concat([provider.name])}.from(context);
            if (item == null) {
              return null;
            }
            item;
          }
        });
      }
      var expr:Expr = {
        expr: EObjectDecl(resolvedFields),
        pos: (macro null).pos
      };

      builder.add(macro class {
        function resolve(context:pine.Context):Null<$ct> {
          return ${expr};
        }
      });

      Context.defineType({
        pack: pack,
        name: consumerName,
        pos: (macro null).pos,
        kind: createClassKind(ct),
        fields: builder.export()
      });
    }

    return TPath(consumerPath);
  }

  static function buildConsumer(type:Type) {
    var pack = ['pine'];
    var name = 'Consumer';
    var ct = type.toComplexType();
    var consumerName = name + '_' + type.stringifyTypeForClassName();
    var consumerPath:TypePath = {pack: pack, name: consumerName, params: []};

    if (!consumerPath.typePathExists()) {
      var provider = switch ProviderBuilder.buildProvider(type) {
        case TPath(p): p;
        default: throw 'assert';
      }
      var builder = createBuilderWithDefaults();

      builder.add(macro class {
        function resolve(context:pine.Context):Null<$ct> {
          return $p{provider.pack.concat([provider.name])}.from(context);
        }
      });

      Context.defineType({
        pack: pack,
        name: consumerName,
        pos: (macro null).pos,
        kind: createClassKind(ct),
        meta: [],
        fields: builder.export()
      });
    }

    return TPath(consumerPath);
  }

  static function createBuilderWithDefaults() {
    var builder = new ClassBuilder([]);
    builder.add(macro class {
      static final type = new pine.UniqueId();

      function getComponentType() {
        return type;
      }
    });
    return builder;
  }

  static function createClassKind(ct:ComplexType):TypeDefKind {
    return TDClass({
      pack: ['pine'],
      name: 'Consumer',
      sub: 'ConsumerComponent',
      params: [TPType(ct)]
    }, [], false, true, false);
  }
}
