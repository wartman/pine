package pine.router;

import haxe.macro.Context;
import haxe.macro.Expr;

using Lambda;
using StringTools;
using haxe.io.Path;

typedef RouteMeta = {
  public final matcher:Expr;
  public final paramsType:ComplexType;
  public final paramsBuilder:Expr;
  public final urlBuilder:Expr;
}

function processRoute(url:String):RouteMeta {
  var pos = Context.getLocalClass().get().pos;
  var parser = new RouteParser(url);
  var matcher = macro new EReg($v{parser.getMatcher()}, '');
  var parts = parser.getParts();
  var params = parser.getParams();
  var fields:Array<Field> = [ for (entry in params) switch entry.type {
    case 'Int': { name: entry.key, kind: FVar(macro:Int), pos: pos };
    default: { name: entry.key, kind: FVar(macro:String), pos: pos };
  } ];
  var paramsBuilder:Expr = {
    expr: EObjectDecl([ for (i in 0...fields.length) {
      field: fields[i].name,
      expr: switch params[i].type {
        case 'Int': macro Std.parseInt(matcher.matched($v{i + 1}));
        default: macro matcher.matched($v{i + 1});
      }
    } ]),
    pos: pos
  };

  var urlBuilder:Array<Expr> = [ macro $v{parts[0]} ];
  for (i in 0...params.length) {
    var key = params[i].key;
    urlBuilder.push(switch params[i].type {
      case 'String': macro props.$key;
      default: macro Std.string(props.$key);
    });
    if (parts[i + 1] != null) {
      urlBuilder.push(macro $v{parts[i + 1]});
    }
  }

  return {
    matcher: matcher,
    paramsBuilder: paramsBuilder,
    paramsType: TAnonymous(fields),
    urlBuilder: macro [ $a{urlBuilder} ].join('')
  };
}

function normalizeUrl(url:String) {
  url = url.normalize().trim();
  if (!url.startsWith('/')) {
    url = '/' + url;
  }
  return url;
}
