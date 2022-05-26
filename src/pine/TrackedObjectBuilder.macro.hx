package pine;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import pine.macro.ClassBuilder;

using haxe.macro.Tools;
using pine.macro.MacroTools;

class TrackedObjectBuilder {
  public static function buildGeneric() {
    return switch Context.getLocalType() {
      case TInst(_, [type]):
        buildTrackedObject(type);
      case TInst(_, []):
        buildTrackedObject((macro:Dynamic).toType());
      default:
        throw 'assert';
    }
  }

  static function buildTrackedObject(type:Type):ComplexType {
    var pack = ['pine'];
    var name = 'TrackedObject_' + resolveName(type);
    var ct = type.toComplexType();
    var path:TypePath = {pack: pack, name: name};

    if (!path.typePathExists()) {
      var builder = new ClassBuilder([]);
      var inits:Array<Expr> = [];
      var dispose:Array<Expr> = [];

      switch ct {
        case TAnonymous(props):
          for (prop in props) switch prop.kind {
            case FVar(t, e): switch t {
              case macro:Array<$t>:
                var name = prop.name;
                if (e == null) e = macro [];
                var init = macro props.$name == null ? $e : props.$name;
                inits.push(macro this.$name = new pine.TrackedArray($init));
                dispose.push(macro this.$name.dispose());
                builder.add(macro class {
                  public final $name:pine.TrackedArray<$t>;
                });
              case macro:Map<$k, $v>:
                var name = prop.name;
                if (e == null) e = macro [];
                var init = macro props.$name == null ? $e : props.$name;
                inits.push(macro this.$name = new pine.TrackedMap($init));
                dispose.push(macro this.$name.dispose());
                builder.add(macro class {
                  public final $name:pine.TrackedMap<$k, $v>;
                });
              default:
                var name = prop.name;
                var signal = 'signal_$name';
                var setter = 'set_$name';
                var getter = 'get_$name';
                var init = e == null ? macro props.$name : macro props.$name == null ? $e : props.$name;
  
                inits.push(macro this.$signal = new pine.Signal($init));
                dispose.push(macro this.$signal.dispose());
                builder.add(macro class {
                  final $signal:pine.Signal<$t>;
  
                  public var $name(get, set):$t;
  
                  inline function $getter():$t return this.$signal.get();
  
                  inline function $setter(value):$t return this.$signal.set(value);
                });
            }
          default:
            Context.error('Only vars are allowed here', prop.pos);
        }
        default:
          Context.error('Expected an anonymous object', Context.currentPos());
      }

      builder.add(macro class {
        public function new(props) {
          $b{inits}
        }

        public function dispose() {
          $b{dispose}
        }
      });

      Context.defineType({
        pack: pack,
        name: name,
        pos: Context.currentPos(),
        kind: TDClass(null, [
          {
            pack: pack,
            name: 'Disposable'
          }
        ], false, true, false),
        fields: builder.export()
      });
    }

    return TPath(path);
  }

  static function resolveName(type:Type):String {
    var ct = type.toComplexType();
    var name = switch ct {
      case TAnonymous(fields):
        var sorted = fields.copy();
        // Ensure the order of fields doesn't matter.
        sorted.sort((a, b) -> a.name > b.name ? -1 : a.name < b.name ? 1 : 0);
        sorted.map(f -> f.name + '_' + switch f.kind {
          case FVar(t, _): t.toString();
          case FFun(f): f.args.map(f -> f.name + '_' + f.type.toString()).concat([f.ret.toString()]).join('_');
          case FProp(get, set, t, _): get + '_' + set + '_' + t.toString();
        }).join('__');
      default:
        Context.error('Expected an anonymous object', Context.currentPos());
        '';
    }
    return haxe.crypto.Md5.encode(name);
  }
}
