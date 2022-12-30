package pine.state;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import pine.macro.ClassBuilder;

using haxe.macro.Tools;
using pine.macro.MacroTools;
using pine.core.Hash;

function buildGeneric() {
  return switch Context.getLocalType() {
    case TInst(_, [type]):
      buildTrackedObject(type);
    case TInst(_, []):
      buildTrackedObject((macro:Dynamic).toType());
    case TInst(_, params):
      var type = params.shift();
      var params = params.map(p -> switch p {
        case TInst(_.get() => {kind: KExpr(macro $v{(name:String)})}, _):
          name;
        default:
          Context.error('Expected a string', Context.currentPos());
          '';
      });
      buildTrackedObject(type, params);
    default:
      throw 'assert';
  }
}

private function buildTrackedObject(type:Type, ?params:Array<String>):ComplexType {
  if (params == null) params = [];

  var pack = ['pine', 'state'];
  var name = 'TrackedObject_' 
    + resolveName(type) 
    + if (params.length > 0) params.join('_').hash() else '';
  var ct = type.toComplexType();
  var path:TypePath = {
    pack: pack,
    name: name,
    params: params.map(p -> TPType(TPath({ pack: [], name: p })))
  };

  if (!path.typePathExists()) {
    var builder = new ClassBuilder([]);
    var inits:Array<Expr> = [];
    var updates:Array<Expr> = [];
    var dispose:Array<Expr> = [];

    hack_fixCompilerTypingOrder();

    switch ct {
      case TAnonymous(props):
        for (prop in props) switch prop.kind {
          case FVar(t, e): switch t {
            case macro:Array<$t>:
              var name = prop.name;
              if (e == null) e = macro [];
              var init = macro props.$name == null ? $e : props.$name;
              inits.push(macro this.$name = new pine.state.TrackedArray($init));
              updates.push(macro this.$name.replace(props.$name));
              dispose.push(macro this.$name.dispose());
              builder.add(macro class {
                public final $name:pine.state.TrackedArray<$t>;
              });
            case macro:Map<$k, $v>:
              var name = prop.name;
              if (e == null) e = macro [];
              var init = macro props.$name == null ? $e : props.$name;
              inits.push(macro this.$name = new pine.state.TrackedMap($init));
              updates.push(macro this.$name.replace(props.$name));
              dispose.push(macro this.$name.dispose());
              builder.add(macro class {
                public final $name:pine.state.TrackedMap<$k, $v>;
              });
            default:
              var name = prop.name;
              var signal = '__signal_$name';
              var setter = 'set_$name';
              var getter = 'get_$name';
              var init = e == null ? macro props.$name : macro props.$name == null ? $e : props.$name;

              inits.push(macro this.$signal = new pine.state.Signal($init));
              updates.push(macro this.$signal.set(props.$name));
              dispose.push(macro this.$signal.dispose());
              builder.add(macro class {
                final $signal:pine.state.Signal<$t>;

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

      public function replace(props) {
        $b{updates};
      }
    });

    Context.defineType({
      pack: pack,
      name: name,
      pos: Context.currentPos(),
      params: [ for (param in params) ({ name: param }:TypeParamDecl) ],
      kind: TDClass(null, [
        {
          pack: [ 'pine', 'core' ],
          name: 'Disposable'
        }
      ], false, true, false),
      fields: builder.export()
    });
  }

  return TPath(path);
}

private function resolveName(type:Type):String {
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
  return name.hash();
}

// @todo: find a better solution for this hack
private function hack_fixCompilerTypingOrder() {
  // This is a hack: it forces the compiler to have `pine.state.Signal` typed 
  // before it defines the tracked object. If we don't do this, we may 
  // run into some odd cases where compiling fails (that is, if we don't
  // import pine.state.Signal somewhere else first).
  //
  // I may just be doing something wrong here
  function ensure(path:String) {
    var cls = Context.getType(path);
    switch cls {
      case TInst(t, params):
        @:keep t.get();
      default: 
        throw 'assert';
    }
  }
  ensure('pine.state.Observer');
  ensure('pine.state.Signal');
}