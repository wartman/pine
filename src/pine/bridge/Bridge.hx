package pine.bridge;

import kit.file.FileSystem;
import kit.file.adaptor.SysAdaptor;
import kit.http.Request;
import pine.html.server.*;
import pine.router.*;

using pine.html.server.PrimitiveTools;

class Bridge extends Structure {
	public inline static function build(props) {
		return new Bridge(props);
	}

	// @:constant final client:ClientConfig = { hxml: 'dependencies' };
	@:constant final client:ClientConfig = {};
	@:constant final children:() -> Child;
	@:constant final onComplete:() -> Void = null;

	public function generate():Task<AppContext> {
		var root = new FileSystem(new SysAdaptor(Sys.getCwd()));
		var assets = new AppContext(client, root.directory(client.outputDirectory));
		var islands = new IslandContext();
		var visitor = new RouteVisitor();

		assets.addAsset(new ClientAppAsset(client, islands));
		visitor.enqueue('/');

		return renderUntilComplete(assets, islands, visitor)
			.next(documents -> {
				for (asset in documents) assets.addAsset(asset);
				return assets;
			});
	}

	function renderUntilComplete(assets:AppContext, islands:IslandContext, visitor:RouteVisitor):Task<Array<HtmlAsset>> {
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

	function renderPath(path:String, assets:AppContext, islands:IslandContext, visitor:RouteVisitor):Task<HtmlAsset> {
		return new Task(activate -> {
			var document = new ElementPrimitive('#document', {});
			var root:Null<View> = null;
			var suspended = false;
			var activated = false;

			function checkActivation() {
				if (activated) throw 'Activated more than once on a render';
				activated = true;
			}

			function sendHtml(path:String, document:ElementPrimitive) {
				if (onComplete != null) onComplete();

				var html = new HtmlAsset(path, document.toString({
					useMarkers: primitive -> primitive.findAncestor(parent -> switch Std.downcast(parent, ElementPrimitive) {
						case null: false;
						case element: element.tag == IslandElement.tag;
					}).map(_ -> true).or(false)
				}));

				root?.dispose();
				activate(Ok(html));
			}

			root = Root.build(document, new ServerAdaptor(), () -> Provider
				.provide(assets)
				.provide(client)
				.provide(islands)
				.provide(visitor)
				.provide(new Navigator({
					request: new Request(Get, path)}))
				.children(
					Suspense.wrap(children())
						.onSuspended(() -> suspended = true)
						.onComplete(() -> {
							checkActivation();
							sendHtml(path, document);
						})
						.onFailed(() -> {
							checkActivation();
							activate(Error(new Error(InternalError, 'Rendering failed')));
						})
						.build()
				)
			).create();

			if (suspended == false) {
				checkActivation();
				sendHtml(path, document);
			}
		});
	}
}
