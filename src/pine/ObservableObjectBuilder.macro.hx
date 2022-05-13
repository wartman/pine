package pine;

import pine.macro.ClassBuilder;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;

using haxe.macro.Tools;
using pine.macro.MacroTools;

class ObservableObjectBuilder {
  public static function buildGeneric() {
    return switch Context.getLocalType() {
      case TInst(_, [type]):
        buildObservableObject(type);
      case TInst(_, []):
        buildObservableObject((macro:Dynamic).toType());
      default:
        throw 'assert';
    }
  }

  static function buildObservableObject(type:Type) {
    var pack = ['pine'];
    var name = 'ObservableObject_' + resolveName(type);
    var ct = type.toComplexType();
    var path:TypePath = {pack: pack, name: name};

    if (!MacroTools.typeExists(pack.concat([name]).join('.'))) {
      var builder = new ClassBuilder([]);
      var inits:Array<Expr> = [];
      var dispose:Array<Expr> = [];

      function observableInit(name:String, link:String, obs:Expr) {
        builder.add(macro class {
          var $link:Null<pine.Disposable> = null;
        });
        inits.push(macro {
          if (this.observedValue.$name != null) {
            this.$link = $obs.bindNext(_ -> notify());
          }
        });
        dispose.push(macro {
          if (this.$link != null) {
            this.$link.dispose();
            this.$link = null;
          }
        });
      }

      function observableSetter(name:String, link:String, obs:Expr) {
        observableInit(name, link, obs);
        return macro {
          if (this.observedValue.$name == value) {
            return value;
          }
          if (this.$link != null) {
            this.$link.dispose();
          }
          this.observedValue.$name = value;
          this.$link = $obs.bindNext(_ -> notify());
          notify();
          return value;
        }
      }

      switch ct {
        case TAnonymous(props):
          for (prop in props) {
            switch prop.kind {
              case FVar(t, _):
                var name = prop.name;
                var setter = 'set_$name';
                var getter = 'get_$name';
                var link = 'link_$name';
                var type = t.toType();

                if (prop.access.contains(AFinal)) {
                  if (Context.unify(type, Context.getType('pine.ObservableHost'))) {
                    observableInit(name, link, macro this.observedValue.$name.observe());
                  }
                  builder.add(macro class {
                    public var $name(get, never):$t;

                    inline function $getter():$t return value.$name;
                  });
                } else {
                  var setterExpr:Expr = if (Context.unify(type, Context.getType('pine.ObservableHost'))) {
                    observableSetter(name, link, macro this.observedValue.$name.observe());
                  } else {
                    macro {
                      if (this.observedValue.$name == value) {
                        return value;
                      }
                      this.observedValue.$name = value;
                      notify();
                      return value;
                    }
                  }
                  builder.add(macro class {
                    public var $name(get, set):$t;

                    inline function $getter():$t return this.observedValue.$name;

                    function $setter(value):$t {
                      $setterExpr;
                    }
                  });
                }
              default:
                Context.error('Only vars are allowed here', prop.pos);
            }
          }
        default:
          Context.error('Expected an anonymous object', Context.currentPos());
      }

      if (inits.length > 0 || dispose.length > 0) {
        builder.add(macro class {
          public function new(props) {
            super(props);
            $b{inits}
          }

          override function dispose() {
            super.dispose();
            $b{dispose}
          }
        });
      }

      Context.defineType({
        pack: pack,
        name: name,
        pos: Context.currentPos(),
        kind: TDClass({
          pack: pack,
          name: 'Observable',
          params: [TPType(ct)]
        }, [], false, true, false),
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
        // Ensre the order of fields doesn't matter.
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
