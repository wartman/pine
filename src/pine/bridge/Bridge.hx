package pine.bridge;

import kit.file.FileSystem;
import kit.file.adaptor.SysAdaptor;
import kit.http.Request;
import pine.html.server.*;
import pine.router.*;

using Kit;
using pine.html.server.PrimitiveTools;

class Bridge extends Model {
  public inline static function build(props) {
    return new Bridge(props);
  }
  
  @:constant final client:ClientConfig = { hxml: 'dependencies' };
  @:constant final children:()->Child;
  @:constant final onComplete:()->Void = null;

  public function generate():Task<AssetContext> {
    var root = new FileSystem(new SysAdaptor(Sys.getCwd()));
    var assets = new AssetContext(client, root.directory(client.outputDirectory));
    var islands = new IslandContext();
    var visitor = new RouteVisitor();
    
    assets.addAsset(new IslandAsset(client, islands));
    visitor.enqueue('/');

    return renderUntilComplete(assets, islands, visitor)
      .next(documents -> {
        for (asset in documents) assets.addAsset(asset);
        return assets;
      });
  }

  function renderUntilComplete(
    assets:AssetContext,
    islands:IslandContext,
    visitor:RouteVisitor
  ):Task<Array<HtmlAsset>> {
    var paths = visitor.drain();
    trace(paths);
    return Task
      .parallel(...paths.map(path -> renderPath(path, assets, islands, visitor)))
      .next(documents -> {
        if (visitor.hasPending()) {
          return renderUntilComplete(assets, islands, visitor)
            .next(moreDocuments -> documents.concat(moreDocuments));
        }
        return documents;
      });
  }
  
  function renderPath(
    path:String,
    assets:AssetContext,
    islands:IslandContext,
    visitor:RouteVisitor
  ):Task<HtmlAsset> {
    return new Task(activate -> {
      var document = new ElementPrimitive('#document', {});
      var suspended = false;
      var activated = false;

      Root.build(document, new ServerAdaptor(), () -> Provider
        .provide(assets)
        .provide(client)
        .provide(islands)
        .provide(visitor)
        .provide(new Navigator({ request: new Request(Get, path) }))
        .children(Suspense.build({
          onSuspended: () -> {
            suspended = true;
          },
          onComplete: () -> {
            if (onComplete != null) onComplete();
            if (activated) throw 'Activated more than once on a render';
            activated = true;
            activate(Ok(new HtmlAsset(path, document.toString())));
          },
          onFailed: () -> {
            if (activated) throw 'Activated more than once on a render';
            activated = true;
            activate(Error(new Error(InternalError, 'Rendering failed')));
          },
          children: children()
        }))
      ).create();

      if (suspended == false) {
        activated = true;
        activate(Ok(new HtmlAsset(path, document.toString({
          // Only output markers on islands.
          useMarkers: primitive -> primitive.findAncestor(parent -> switch Std.downcast(parent, ElementPrimitive) {
            case null: false;
            case element: element.tag == IslandElement.tag;
          }).map(_ -> true).or(false)
        }))));
      }
    });
  }
}
