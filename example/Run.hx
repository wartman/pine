import haxe.io.Path;
import pine.bridge.Bridge;
import pine.router.Router;
import site.data.FileSystemContext;
import site.page.*;

function main() {
  Bridge.build({
    client: {
      // @todo: Come up with a better way to handle Breeze.
      flags: [ '-D breeze.output=none' ],
      outputName: '/assets/app.js'
    },
    children: () -> Provider
      .provide(new FileSystemContext(Path.join([
        Sys.getCwd(),
        'example'
      ])))
      .children(
        Router.build({
          routes: [
            HomePage.route(),
            TodoPage.route(),
            CounterPage.route(),
            PostPage.route(),
            ComponentExamplesPage.route()
          ],
          fallback: _ -> 'Page not found'
        })
      )
  })
  .generate()
  .next(assets -> assets.process())
  .handle(result -> switch result {
    case Ok(_): trace('Site generated');
    case Error(error): trace(error.message);
  });
}
