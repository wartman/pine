package pine.bridge;

import pine.html.server.*;

using Kit;

class ClientConfig extends Model {
  @:constant public final sources:Array<String> = [ 'src' ];
  @:constant public final outputDirectory:String = 'temp';
  @:constant public final outputName:String = 'index.js';
  @:constant public final libraries:Array<String> = [];
  @:constant public final flags:Array<String> = [];
}

class Bridge extends Model {
  public inline static function build(props) {
    return new Bridge(props);
  }
  
  @:constant final client:ClientConfig = new ClientConfig({});
  @:constant final children:()->Child;
  @:constant final onComplete:()->Void = null;

  public function generate():Task<AssetContext> {
    var assets = new AssetContext(client);
    var islands = new IslandContext();
    var visitor = new RouteVisitor();
    
    assets.addAsset(new IslandAsset({}, islands));
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
      // @todo: use a Document api
      var document = new ElementPrimitive('#fragment', {});
      var suspended = false;
      var activated = false;

      Root.build(document, new ServerAdaptor(), () -> Provider
        .provide(assets)
        .provide(client)
        .provide(islands)
        .provide(visitor)
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
        activate(Ok(new HtmlAsset(path, document.toString())));
      }
    });
  }
}
