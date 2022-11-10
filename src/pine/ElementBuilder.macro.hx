package pine;

import haxe.macro.Context;
import haxe.macro.Expr;
import pine.macro.ClassBuilder;

using haxe.macro.Tools;
using StringTools;

function build() {
  var builder = new ClassBuilder(Context.getBuildFields());
  var cls = Context.getLocalClass().get();

  if (cls.meta.has('component')) {
    switch cls.meta.extract('component') {
      case [ { params: [ type ], pos: pos } ]:
        var name = resolveNameFromExpr(type);
        var complexType = resolveTypeFromExpr(type);
        var getter = 'get_$name';
        
        // @todo: Check that complexType is valid

        builder.add(macro class {
          var $name(get, never):$complexType;
          inline function $getter():$complexType return getComponent();
        });

        switch builder.findField('new') {
          case Some(_):
          case None: builder.add(macro class {
            public function new($name:$complexType) {
              super($i{name});
            }
          });
        }
      case [ { params: [], pos: pos } ]:
        Context.error('Argument expected', pos);
      case [ { params: params, pos: pos } ]:
        Context.error('Too many arguments', params[1].pos);
      case metas:
        Context.error('Only one @component metadata is allowed per Element', metas[1].pos);
    }

    cls.meta.remove('component');
  }

  return builder.export();
}

function resolveTypeFromExpr(type:Expr):ComplexType {
  return switch type.expr {
    case ECall(e, params):
      var pack = e.toString().split('.');
      var name = pack.pop();
      var params = params.map(resolveTypeFromExpr);
      return TPath({
        pack: pack,
        name: name,
        params: params.map(ct -> TPType(ct)) 
      });
    default:
      type.toString().toComplex();
  }
}

function resolveNameFromExpr(type:Expr) {
  return switch type.expr {
    case ECall(e, params):
      resolveNameFromExpr(e);
    default:
      lcFirst(type.toString().split('.').pop());
  }
}

function lcFirst(str:String) {
  var first = str.charAt(0).toLowerCase();
  return first + str.substr(1);
}
