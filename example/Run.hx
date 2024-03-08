import pine.bridge.Bridge;
import pine.router.Router;
import site.page.*;

function main() {
  Bridge.build({
    client: {
      // hxml: 'dependencies',
      // @todo: Come up with a better way to handle Breeze.
      flags: [ '-D breeze.output=none' ]
    },
    children: () -> Router.build({
      routes: [
        HomePage.route(),
        TodoPage.route(),
        CounterPage.route()
      ],
      fallback: _ -> 'Page not found'
    })
  })
  .generate()
  .next(assets -> assets.process())
  .handle(result -> switch result {
    case Ok(_): trace('Site generated');
    case Error(error): trace(error.message);
  });
}
