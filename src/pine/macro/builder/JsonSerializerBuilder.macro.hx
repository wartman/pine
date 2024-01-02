package pine.macro.builder;

import haxe.macro.Expr;
import haxe.macro.Context;

using Lambda;
using haxe.macro.Tools;
using pine.macro.MacroTools;

typedef JsonSerializerBuilderOptions = {
  public final ?constructorAccessor:Expr;
  public final ?returnType:ComplexType;
}

typedef JsonSerializerHook = {
  public final serializer:Expr;
  public final deserializer:Expr;
}

class JsonSerializerBuilder implements Builder {
  public final priority:BuilderPriority = Late;

  final options:JsonSerializerBuilderOptions;

  public function new(options) {
    this.options = options;
  }

  public function apply(builder:ClassBuilder) {
    var ret = options.returnType ?? builder.getComplexType();
    var fields = builder.getProps('new');
    var serializer:Array<ObjectField> = [];
    var deserializer:Array<ObjectField> = [];
    
    for (field in fields) {
      var result = parseField(builder, field);
      serializer.push({ field: field.name, expr: result.serializer });
      deserializer.push({ field: field.name, expr: result.deserializer });
    }
    
    var serializerExpr:Expr = {
      expr: EObjectDecl(serializer),
      pos: (macro null).pos
    };
    var deserializerExpr:Expr = {
      expr: EObjectDecl(deserializer),
      pos: (macro null).pos
    };

    var constructors = switch options.constructorAccessor {
      case null: 
        var clsTp = builder.getTypePath();
        macro class {
          public static function fromJson(data:{}):$ret {
            return new $clsTp($deserializerExpr);
          }
        }
      case access:
        macro class {
          public static function fromJson(data:{}):$ret {
            return $access($deserializerExpr);
          }
        }
    };

    builder.addField(constructors
      .getField('fromJson')
      .unwrap()
      .applyParameters(builder.getClass().params.toTypeParamDecl()));

    builder.add(macro class {
      public function toJson():Dynamic {
        return $serializerExpr;
      }
    });
  }

  function parseField(builder:ClassBuilder, prop:Field):JsonSerializerHook {
    var field:Field = switch builder.findField(prop.name) {
      case Some(field): field;
      case None: prop;
    }

    var def = switch field.kind {
      case FVar(_, e) if (e != null): e;
      default: macro null;
    }

    return switch field.kind {
      case FVar(t, _) | FProp(_, _, t):
        var meta = field.getMetadata(':json');
        var name = field.name;
        var access = switch t {
          case _ if (t.isSignal()): macro this.$name.get();
          default: macro this.$name;
        }

        t = switch t.toType().toComplexType() {
          case macro:pine.signal.Signal<$t>: t;
          default: t;
        }
    
        if (meta != null) return switch meta.params {
          case [ macro to = ${to}, macro from = ${from} ] | [ macro from = ${from}, macro to = ${to} ]:
            var serializer = macro {
              var value = $access;
              if (value == null) null else $to;
            };
            var deserializer = switch t {
              case macro:Array<$_>:
                macro {
                  var value:Array<Dynamic> = Reflect.field(data, $v{name});
                  if (value == null) value = [];
                  $from;
                };
              default:
                macro {
                  var value:Dynamic = Reflect.field(data, $v{name});
                  if (value == null) $def else ${from};
                };
            }

            {
              serializer: serializer,
              deserializer: deserializer
            };
          case []:
            Context.error('There is no need to mark fields with @:json unless you are defining how they should serialize/unserialize', meta.pos);
          default:
            Context.error('Invalid arguments', meta.pos);
        }
        
        switch t {
          case macro:Dynamic:
            {
              serializer: access,
              deserializer: macro Reflect.field(data, $v{name})
            };
          case macro:Null<$t> if (t.isModel()):
            var path = switch t {
              case TPath(p): p.typePathToArray();
              default: Context.error('Could not resolve type', field.pos);
            }

            {
              serializer: macro $access?.toJson(),
              deserializer: macro {
                var value:Dynamic = Reflect.field(data, $v{name});
                if (value == null) null else  $p{path}.fromJson(value);
              }
            };
          case macro:Array<$t> if (t.isModel()):
            var path = switch t {
              case TPath(p): p.typePathToArray();
              default: Context.error('Could not resolve type', field.pos);
            }
            
            {
              serializer: macro $access.map(item -> item.toJson()),
              deserializer: macro {
                var values:Array<Dynamic> = Reflect.field(data, $v{name});
                values.map($p{path}.fromJson);
              }
            };
          case t if (t.isModel()):
            var path = switch t {
              case TPath(p): p.typePathToArray();
              default: Context.error('Could not resolve type', field.pos);
            }

            {
              serializer: macro $access?.toJson(),
              deserializer: macro {
                var value:Dynamic = Reflect.field(data, $v{name});
                $p{path}.fromJson(value);
              }
            }
          default:
            {
              serializer: access,
              deserializer: macro Reflect.field(data, $v{name})
            };
        }
      default:
        Context.error('Invalid field for json serialization', field.pos);
    }
  }
}
