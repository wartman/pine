package pine.bridge;

import haxe.macro.Context;
import haxe.macro.Expr;
import pine.macro.*;
import pine.macro.builder.*;

using kit.Hash;
using pine.macro.Tools;
using pine.bridge.RouteBuilder;
using pine.macro.Tools;

final factory = new ClassBuilderFactory([
  new ConstructorBuilder({
    customBuilder: options -> {
      (macro function(url, params) {
        this.url = url;
        this.params = params;
        ${options.previousExpr.or(macro null)}
      }).extractFunction();
    }
  })
]);

function buildGeneric() {
  return switch Context.getLocalType() {
    case TInst(_, [ TInst(_.get() => {kind: KExpr(macro $v{(url:String)})}, _) ]):
      buildPageRoute(url.normalizeUrl());
    default:
      throw 'assert';
  }
}

function build(url:String) {
  return factory
    .withBuilders(new PageBuilder(url))
    .fromContext()
    .export();
}

private function buildPageRoute(url:String) {
  var suffix = url.hash();
  var pos = Context.getLocalClass().get().pos;
  var pack = [ 'pine', 'routing' ];
  var name = 'Page_${suffix}';
  var path:TypePath = { pack: pack, name: name, params: [] };

  if (path.typePathExists()) return TPath(path);

  var builder = new ClassFieldCollection([]);

  Context.defineType({
    pack: pack,
    name: name,
    pos: pos,
    meta: [
      {
        name: ':autoBuild',
        params: [ macro pine.bridge.PageBuilder.build($v{url}) ],
        pos: pos
      },
      {
        name: ':remove',
        params: [],
        pos: pos
      }
    ],
    kind: TDClass({
      pack: [ 'pine' ],
      name: 'ReactiveView'
    }, [], false, false, true),
    fields: builder.export()
  });

  return TPath(path);
}

class PageBuilder implements Builder {
  public final priority:BuilderPriority = Late;

  final url:String;

  public function new(url) {
    this.url = url;
  }

  public function apply(builder:ClassBuilder) {
    var route = url.processRoute();
    var routeParamsType = route.paramsType;
    var path = builder.getTypePath();
    
    builder.add(macro class {
      static final matcher = ${route.matcher};

      public static function route():pine.bridge.Route {
        return new pine.bridge.Route.SimpleRoute(request -> {
          if (request.method != Get) return None;
          if (matcher.match(request.url)) {
            return Some(() -> new $path(request.url, ${route.paramsBuilder}));
          }
          return None;
        });
      }
  
      public static function createUrl(props:$routeParamsType):String {
        return ${route.urlBuilder};
      }

      public static function link(props:$routeParamsType) {
        return pine.bridge.Link.to(createUrl(props));
      }

      final url:String;
      final params:$routeParamsType;
    });
  }
}
