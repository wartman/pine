import haxe.io.Path;
import pine.bridge.Bridge;
import pine.router.*;
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
            new Route<"/">(_ -> HomePage.build({})),
            new Route<"/todos">(_ -> TodoPage.build({})),
            new Route<"/counter/{initialCount:Int}">(params -> CounterPage.build(params)),
            new Route<"/post/{id:Int}">(params -> PostPage.build(params)),
            new Route<"/component-examples">(_ -> ComponentExamplesPage.build({}))
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
