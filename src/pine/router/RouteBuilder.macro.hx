package pine.router;

import haxe.macro.Context;
import haxe.macro.Expr;
import pine.macro.*;
import pine.macro.builder.*;

using kit.Hash;
using pine.macro.Tools;
using pine.router.RouteTools;
using pine.macro.Tools;

function buildGeneric() {
  return switch Context.getLocalType() {
    case TInst(_, [ TInst(_.get() => {kind: KExpr(macro $v{(url:String)})}, _) ]):
      buildRoute(url.normalizeUrl());
    default:
      throw 'assert';
  }
}

function buildRoute(url:String) {
  var suffix = url.hash();
  var pos = Context.getLocalClass().get().pos;
  var pack = [ 'pine', 'router' ];
  var name = 'Route_${suffix}';
  var path:TypePath = { pack: pack, name: name, params: [] };

  if (path.typePathExists()) return TPath(path);
  
  var builder = new ClassFieldCollection([]);
  var route = url.processRoute();
  var routeParamsType = route.paramsType;
  var renderType = macro:(params:$routeParamsType)->pine.Child;
  
  builder.add(macro class {
    static final matcher = ${route.matcher};
  
    public static function createUrl(props:$routeParamsType):String {
      return ${route.urlBuilder};
    }

    public static function link(props:$routeParamsType) {
      return pine.router.Link.to(createUrl(props));
    }

    final render:$renderType;

    public function new(render) {
      this.render = render;
    }

    public function match(request:kit.http.Request):kit.Maybe<()->pine.Child> {
      if (request.method != Get) return None;
      if (matcher.match(request.url)) {
        return Some(() -> render(${route.paramsBuilder}));
      }
      return None;
    }
  });

  Context.defineType({
    pack: pack,
    name: name,
    pos: pos,
    meta: [],
    kind: TDClass(null, [
      {
        pack: ['pine', 'router'],
        name: 'Matchable'
      }
    ], false, true, false),
    fields: builder.export()
  });

  return TPath(path);
}
