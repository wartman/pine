package pine.bridge;

import haxe.macro.Context;
import haxe.macro.Expr;
import pine.macro.*;
import pine.macro.builder.*;

using kit.Hash;
using pine.macro.Tools;
using pine.bridge.RouteBuilder;

final factory = new ClassBuilderFactory([
  new AttributeFieldBuilder(),
  new ObservableFieldBuilder(),
  new SignalFieldBuilder(),
  new ComputedFieldBuilder(),
  new ConstructorBuilder({})
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
    kind: TDClass(null, [
      {
        pack: [ 'pine', 'bridge' ],
        name: 'Route'
      }
    ], true, false, false),
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
    
    builder.add(macro class {
      static final matcher = ${route.matcher};
  
      public static function createUrl(props:$routeParamsType):String {
        return ${route.urlBuilder};
      }

      public static function link(props:$routeParamsType) {
        return pine.bridge.Link.to(createUrl(props));
      }

      final url = new pine.signal.Signal<Null<String>>(null);
      final params = new pine.signal.Signal<Null<$routeParamsType>>(null);

      public function match(request:kit.http.Request):Bool {
        if (request.method != Get) return false;
        if (matcher.match(request.url)) {
          this.url.set(request.url);
          this.params.set(${route.paramsBuilder});
          return true;
        }
        return false;
      }
    });
  }
}
